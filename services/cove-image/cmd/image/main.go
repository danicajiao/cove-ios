package main

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strconv"

	"github.com/go-chi/chi/v5"

	"github.com/danicajiao/cove/services/cove-image/internal/storage"
)

// commitSHA is set at build time via ldflags:
//
//	go build -ldflags "-X main.commitSHA=$(git rev-parse --short HEAD)" ./cmd/image/
//
// It defaults to "dev" for local builds where the flag is not supplied.
var commitSHA = "dev"

// defaultMaxUploadBytes is 10 MiB.
const defaultMaxUploadBytes = 10 * 1024 * 1024

// allowedContentTypes is the set of MIME types accepted by the upload endpoint.
var allowedContentTypes = map[string]string{
	"image/jpeg": "jpg",
	"image/png":  "png",
	"image/webp": "webp",
}

func main() {
	ctx := context.Background()

	garage, err := storage.NewGarageClient(ctx)
	if err != nil {
		log.Fatalf("failed to initialise Garage client: %v", err)
	}

	maxBytes := int64(defaultMaxUploadBytes)
	if v := os.Getenv("MAX_UPLOAD_BYTES"); v != "" {
		parsed, err := strconv.ParseInt(v, 10, 64)
		if err != nil {
			log.Fatalf("invalid MAX_UPLOAD_BYTES %q: %v", v, err)
		}
		maxBytes = parsed
	}

	r := chi.NewRouter()

	// /health is unauthenticated — used by Kubernetes probes.
	r.Get("/health", healthHandler)

	// All other routes require X-Cove-Uid (injected by cove-api upstream).
	r.Group(func(r chi.Router) {
		r.Use(uidMiddleware)
		r.Post("/images", uploadHandler(garage, maxBytes))
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("cove-image listening on :%s", port)
	if err := http.ListenAndServe(":"+port, r); err != nil {
		log.Fatalf("server error: %v", err)
	}
}

// uidMiddleware rejects requests that do not carry a non-empty X-Cove-Uid
// header with 401 Unauthorized.  cove-image does NOT validate Firebase tokens
// itself — it trusts the UID injected by the upstream cove-api gateway.
func uidMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		uid := r.Header.Get("X-Cove-Uid")
		if uid == "" {
			writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
			return
		}
		next.ServeHTTP(w, r)
	})
}

// uploadResponse is the JSON body returned on a successful upload.
type uploadResponse struct {
	Key string `json:"key"`
	URL string `json:"url"`
}

// uploadHandler returns an http.HandlerFunc that:
//  1. Parses the multipart/form-data body
//  2. Validates content type and size
//  3. Derives a content-addressed key (images/{sha256hex}.{ext})
//  4. Writes the file to Garage
//  5. Returns 201 with {key, url}
func uploadHandler(garage *storage.GarageClient, maxBytes int64) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Limit total body size before parsing the multipart form.
		r.Body = http.MaxBytesReader(w, r.Body, maxBytes+1024) // +1 KiB for field overhead

		if err := r.ParseMultipartForm(maxBytes); err != nil {
			writeJSON(w, http.StatusRequestEntityTooLarge, map[string]string{
				"error": fmt.Sprintf("request body too large or malformed: %v", err),
			})
			return
		}

		file, header, err := r.FormFile("file")
		if err != nil {
			writeJSON(w, http.StatusBadRequest, map[string]string{"error": "missing or invalid 'file' field"})
			return
		}
		defer file.Close()

		// Read entire file into memory so we can detect content type, hash it,
		// and know its exact size. maxBytes is enforced by MaxBytesReader above,
		// so this is bounded.
		data, err := io.ReadAll(file)
		if err != nil {
			writeJSON(w, http.StatusRequestEntityTooLarge, map[string]string{"error": "file exceeds maximum allowed size"})
			return
		}

		if int64(len(data)) > maxBytes {
			writeJSON(w, http.StatusRequestEntityTooLarge, map[string]string{
				"error": fmt.Sprintf("file size %d exceeds limit of %d bytes", len(data), maxBytes),
			})
			return
		}

		// Determine content type: prefer the part's Content-Type header, fall
		// back to sniffing the first 512 bytes of the file data.
		contentType := header.Header.Get("Content-Type")
		if contentType == "" {
			probe := data
			if len(probe) > 512 {
				probe = probe[:512]
			}
			contentType = http.DetectContentType(probe)
		}

		ext, ok := allowedContentTypes[contentType]
		if !ok {
			writeJSON(w, http.StatusUnsupportedMediaType, map[string]string{
				"error": fmt.Sprintf("unsupported content type %q; must be image/jpeg, image/png, or image/webp", contentType),
			})
			return
		}

		// Derive content-addressed object key.
		sum := sha256.Sum256(data)
		hexSum := fmt.Sprintf("%x", sum)
		key := fmt.Sprintf("images/%s.%s", hexSum, ext)

		if err := garage.PutObject(r.Context(), key, contentType, bytes.NewReader(data), int64(len(data))); err != nil {
			log.Printf("ERROR: PutObject key=%q: %v", key, err)
			writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to store image"})
			return
		}

		writeJSON(w, http.StatusCreated, uploadResponse{
			Key: key,
			URL: "/images/" + key,
		})
	}
}

// healthHandler returns 200 with a JSON body identifying the service and Git commit SHA.
func healthHandler(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{
		"service": "cove-image",
		"status":  "ok",
		"commit":  commitSHA,
	})
}

// writeJSON writes a JSON-encoded body with the given HTTP status code.
func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}
