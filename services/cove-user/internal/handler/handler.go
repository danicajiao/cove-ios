// Package handler implements the HTTP handlers for cove-user endpoints.
// All handlers share a Deps struct that holds the database pool and
// build metadata.
package handler

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Deps holds the shared dependencies injected into every handler.
type Deps struct {
	DB        *pgxpool.Pool
	CommitSHA string
}

// writeJSON writes a JSON-encoded body with the given HTTP status code.
func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

// writeError writes a JSON error body with the given HTTP status code.
func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}

// formatUUID converts a pgtype.UUID to its standard hyphenated hex string.
func formatUUID(u pgtype.UUID) string {
	if !u.Valid {
		return ""
	}
	b := u.Bytes
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16])
}

// isNotFound returns true when err is a pgx "no rows" sentinel.
func isNotFound(err error) bool {
	return errors.Is(err, pgx.ErrNoRows)
}
