package handler

import "net/http"

// UIDMiddleware rejects requests that do not carry a non-empty X-Cove-Uid
// header with 401 Unauthorized. cove-user does NOT validate Firebase tokens
// itself — it trusts the UID injected by the upstream cove-api gateway.
func UIDMiddleware(next http.Handler) http.Handler {
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
