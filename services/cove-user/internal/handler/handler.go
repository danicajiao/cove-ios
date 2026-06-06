// Package handler implements the HTTP handlers for cove-user endpoints.
// All handlers share a Deps struct that holds the database store and
// build metadata.
package handler

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Row is the interface satisfied by *pgx.Row — used for QueryRow results.
type Row interface {
	Scan(dest ...any) error
}

// Rows is the interface satisfied by pgx.Rows — used for Query results.
type Rows interface {
	Next() bool
	Scan(dest ...any) error
	Close()
	Err() error
}

// Store abstracts the database operations needed by handlers.
// *pgxpool.Pool satisfies this via poolStore below.
type Store interface {
	QueryRow(ctx context.Context, sql string, args ...any) Row
	Query(ctx context.Context, sql string, args ...any) (Rows, error)
	Exec(ctx context.Context, sql string, args ...any) (pgconn.CommandTag, error)
	Begin(ctx context.Context) (pgx.Tx, error)
}

// poolStore wraps *pgxpool.Pool to satisfy Store.
type poolStore struct{ p *pgxpool.Pool }

func (s *poolStore) QueryRow(ctx context.Context, sql string, args ...any) Row {
	return s.p.QueryRow(ctx, sql, args...)
}

func (s *poolStore) Query(ctx context.Context, sql string, args ...any) (Rows, error) {
	return s.p.Query(ctx, sql, args...)
}

func (s *poolStore) Exec(ctx context.Context, sql string, args ...any) (pgconn.CommandTag, error) {
	return s.p.Exec(ctx, sql, args...)
}

func (s *poolStore) Begin(ctx context.Context) (pgx.Tx, error) {
	return s.p.Begin(ctx)
}

// NewStore wraps a *pgxpool.Pool as a Store. Called from main.go.
func NewStore(p *pgxpool.Pool) Store { return &poolStore{p: p} }

// Deps holds the shared dependencies injected into every handler.
type Deps struct {
	DB        Store
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
