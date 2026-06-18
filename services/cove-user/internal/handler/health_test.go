package handler

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHealthHandler(t *testing.T) {
	deps := &Deps{DB: &mockStore{}, CommitSHA: "abc1234"}
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rr := httptest.NewRecorder()

	deps.HealthHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", rr.Code)
	}

	var body map[string]string
	if err := json.NewDecoder(rr.Body).Decode(&body); err != nil {
		t.Fatalf("decode body: %v", err)
	}

	if got := body["service"]; got != "cove-user" {
		t.Errorf("service: want %q, got %q", "cove-user", got)
	}
	if got := body["status"]; got != "ok" {
		t.Errorf("status: want %q, got %q", "ok", got)
	}
	if got := body["commit"]; got != "abc1234" {
		t.Errorf("commit: want %q, got %q", "abc1234", got)
	}
}
