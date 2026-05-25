package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"

	firebase "firebase.google.com/go/v4"
	"github.com/go-chi/chi/v5"
	"google.golang.org/api/option"

	covauth "github.com/danicajiao/cove/services/cove-api/internal/auth"
)

// commitSHA is set at build time via ldflags:
//
//	go build -ldflags "-X main.commitSHA=$(git rev-parse --short HEAD)" ./cmd/api/
//
// It defaults to "dev" for local builds where the flag is not supplied.
var commitSHA = "dev"

func main() {
	r := chi.NewRouter()

	// /health is unauthenticated and registered first, before any Firebase
	// initialisation, so it is always reachable — including during local
	// development without credentials and by Kubernetes probes during startup.
	r.Get("/health", healthHandler)

	// /i/* proxies to imgproxy unauthenticated — imgproxy validates its own
	// HMAC-SHA256 URL signature, so a Firebase token is not required here.
	// This allows Cloudflare to cache image responses without needing a token.
	imgproxyURL := os.Getenv("IMGPROXY_URL")
	if imgproxyURL == "" {
		imgproxyURL = "http://imgproxy:8080"
	}
	r.Handle("/i/*", imgproxyHandler(imgproxyURL))

	// Initialise Firebase and wire protected routes only when credentials are
	// provided.  Without FIREBASE_CREDENTIALS_PATH the server still starts and
	// /health works; all other routes return 401.
	credPath := os.Getenv("FIREBASE_CREDENTIALS_PATH")
	if credPath != "" {
		ctx := context.Background()

		app, err := firebase.NewApp(ctx, nil, option.WithCredentialsFile(credPath))
		if err != nil {
			log.Fatalf("failed to initialise Firebase app: %v", err)
		}

		authClient, err := app.Auth(ctx)
		if err != nil {
			log.Fatalf("failed to initialise Firebase Auth client: %v", err)
		}

		// cove-image URL — defaults to the in-cluster Service name, which
		// resolves within the same namespace without a full DNS path.
		coveImageURL := os.Getenv("COVE_IMAGE_URL")
		if coveImageURL == "" {
			coveImageURL = "http://cove-image:8080"
		}

		// All routes except /health and /i/* are protected by Firebase
		// ID-token validation.
		r.Group(func(r chi.Router) {
			r.Use(covauth.Middleware(authClient))

			// /images and /images/* proxy to cove-image. The authenticated
			// UID is injected as X-Cove-Uid so cove-image can trust it
			// without re-validating the Firebase token itself.
			imgHandler := coveImageHandler(coveImageURL)
			r.Handle("/images", imgHandler)
			r.Handle("/images/*", imgHandler)
		})

		log.Println("Firebase Auth initialised — protected routes active")
	} else {
		log.Println("FIREBASE_CREDENTIALS_PATH not set — protected routes disabled (local dev mode)")
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("cove-api listening on :%s", port)
	if err := http.ListenAndServe(":"+port, r); err != nil {
		log.Fatalf("server error: %v", err)
	}
}

// coveImageHandler returns a reverse proxy handler for cove-image.
//
// The handler injects the authenticated Firebase UID as X-Cove-Uid so
// cove-image can trust it without re-validating the token. The full request
// path is forwarded unchanged so cove-image's own router handles dispatch
// (e.g. POST /images vs GET /images/{filename}/url).
func coveImageHandler(targetURL string) http.Handler {
	target, err := url.Parse(targetURL)
	if err != nil {
		log.Fatalf("invalid COVE_IMAGE_URL %q: %v", targetURL, err)
	}
	proxy := httputil.NewSingleHostReverseProxy(target)
	proxy.ErrorHandler = func(w http.ResponseWriter, r *http.Request, err error) {
		log.Printf("ERROR: cove-image proxy: %v", err)
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadGateway)
		_, _ = w.Write([]byte(`{"error":"image service unavailable"}`))
	}
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Propagate the verified UID. cove-image rejects requests without
		// this header — safe because cove-image is not externally reachable.
		if uid, ok := covauth.UIDFromContext(r.Context()); ok {
			r.Header.Set("X-Cove-Uid", uid)
		}
		proxy.ServeHTTP(w, r)
	})
}

// imgproxyHandler returns a reverse proxy handler for imgproxy.
//
// The /i prefix is stripped before forwarding so imgproxy receives the path
// in its expected form: /<signature>/<processing_options>/plain/<source>.
// imgproxy validates its own HMAC-SHA256 URL signature — no Firebase token
// is required at this layer.
func imgproxyHandler(targetURL string) http.Handler {
	target, err := url.Parse(targetURL)
	if err != nil {
		log.Fatalf("invalid IMGPROXY_URL %q: %v", targetURL, err)
	}
	proxy := httputil.NewSingleHostReverseProxy(target)
	proxy.ErrorHandler = func(w http.ResponseWriter, r *http.Request, err error) {
		log.Printf("ERROR: imgproxy proxy: %v", err)
		w.WriteHeader(http.StatusBadGateway)
	}
	// Strip /i so imgproxy sees /<sig>/... rather than /i/<sig>/...
	return http.StripPrefix("/i", proxy)
}

// healthHandler returns 200 with a JSON body identifying the service and the
// Git commit SHA of the running build.  It is intentionally unauthenticated
// so Kubernetes liveness/readiness probes and the iOS smoke test can reach it
// without a token.
func healthHandler(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(map[string]string{
		"service": "cove-api",
		"status":  "ok",
		"commit":  commitSHA,
	})
}
