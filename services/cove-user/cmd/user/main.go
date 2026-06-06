package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/danicajiao/cove/services/cove-user/internal/handler"
)

// commitSHA is set at build time via ldflags:
//
//	go build -ldflags "-X main.commitSHA=$(git rev-parse --short HEAD)" ./cmd/user/
//
// It defaults to "dev" for local builds where the flag is not supplied.
var commitSHA = "dev"

func main() {
	ctx := context.Background()

	// ── Database ─────────────────────────────────────────────────────────────
	dbURL := mustEnv("DATABASE_URL")
	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatalf("failed to create DB pool: %v", err)
	}
	defer pool.Close()

	if err := pool.Ping(ctx); err != nil {
		log.Fatalf("failed to ping database: %v", err)
	}
	log.Printf("database connected")

	// ── Deps ─────────────────────────────────────────────────────────────────
	deps := &handler.Deps{
		DB:        pool,
		CommitSHA: commitSHA,
	}

	// ── Router ────────────────────────────────────────────────────────────────
	r := chi.NewRouter()

	// /health is unauthenticated — used by Kubernetes probes.
	r.Get("/health", deps.HealthHandler)

	// All other routes require X-Cove-Uid (injected by cove-api upstream).
	r.Group(func(r chi.Router) {
		r.Use(uidMiddleware)
		r.Get("/users/me", deps.GetMeHandler)
		r.Get("/users/me/favorites", deps.GetFavoritesHandler)
		r.Post("/users/me/favorites/{itemId}", deps.AddFavoriteHandler)
		r.Delete("/users/me/favorites/{itemId}", deps.RemoveFavoriteHandler)
		r.Get("/users/me/follows", deps.GetFollowsHandler)
		r.Post("/users/me/follows", deps.AddFollowHandler)
		r.Delete("/users/me/follows/{entityId}", deps.RemoveFollowHandler)
		r.Get("/users/me/interests", deps.GetInterestsHandler)
		r.Put("/users/me/interests", deps.ReplaceInterestsHandler)
		r.Post("/users/me/events", deps.IngestEventHandler)
		r.Get("/recommendations/categories", deps.RecommendedCategoriesHandler)
	})

	port := envOr("PORT", "8080")
	log.Printf("cove-user listening on :%s (commit=%s)", port, commitSHA)
	if err := http.ListenAndServe(":"+port, r); err != nil {
		log.Fatalf("server error: %v", err)
	}
}

// uidMiddleware rejects requests that do not carry a non-empty X-Cove-Uid
// header with 401 Unauthorized. cove-user does NOT validate Firebase tokens
// itself — it trusts the UID injected by the upstream cove-api gateway.
func uidMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("X-Cove-Uid") == "" {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusUnauthorized)
			_, _ = w.Write([]byte(`{"error":"unauthorized"}`))
			return
		}
		next.ServeHTTP(w, r)
	})
}

func mustEnv(key string) string {
	v := os.Getenv(key)
	if v == "" {
		log.Fatalf("%s must be set", key)
	}
	return v
}

func envOr(key, defaultVal string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultVal
}
