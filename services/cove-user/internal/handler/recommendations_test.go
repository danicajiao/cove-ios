package handler

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestRecommendedCategoriesHandler_WithInterests(t *testing.T) {
	// First Query (interest-based) returns two categories.
	catID1 := newCategoryUUID("11111111111111111111111111111111")
	catID2 := newCategoryUUID("22222222222222222222222222222222")

	queryCalls := 0
	deps := &Deps{
		DB: &mockStore{
			queryFn: func(ctx context.Context, sql string, args ...any) (Rows, error) {
				queryCalls++
				if queryCalls == 1 {
					return &categoryRows{rows: []categoryRow{
						{id: catID1, name: "Coffee", path: "food.coffee"},
						{id: catID2, name: "Tea", path: "food.tea"},
					}}, nil
				}
				// Second query should not be called when interests exist.
				return &emptyRows{}, nil
			},
		},
		CommitSHA: "test",
	}

	req := httptest.NewRequest(http.MethodGet, "/recommendations/categories", nil)
	req.Header.Set("X-Cove-Uid", "uid-123")
	rr := httptest.NewRecorder()

	deps.RecommendedCategoriesHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", rr.Code)
	}

	var body recommendedCategoriesResponse
	if err := json.NewDecoder(rr.Body).Decode(&body); err != nil {
		t.Fatalf("decode body: %v", err)
	}
	if len(body.Categories) != 2 {
		t.Errorf("expected 2 categories, got %d", len(body.Categories))
	}
	if body.Categories[0].Name != "Coffee" {
		t.Errorf("first category name: got %q, want %q", body.Categories[0].Name, "Coffee")
	}
	if body.Categories[0].Path != "food.coffee" {
		t.Errorf("first category path: got %q, want %q", body.Categories[0].Path, "food.coffee")
	}
	if queryCalls != 1 {
		t.Errorf("expected only the interest query to run, got %d query calls", queryCalls)
	}
}

func TestRecommendedCategoriesHandler_FallbackNoInterests(t *testing.T) {
	// First Query returns empty (no interests), second returns fallback categories.
	catID := newCategoryUUID("33333333333333333333333333333333")

	queryCalls := 0
	deps := &Deps{
		DB: &mockStore{
			queryFn: func(ctx context.Context, sql string, args ...any) (Rows, error) {
				queryCalls++
				if queryCalls == 1 {
					// No interests.
					return &emptyRows{}, nil
				}
				// Fallback global categories.
				return &categoryRows{rows: []categoryRow{
					{id: catID, name: "Pottery", path: "crafts.pottery"},
				}}, nil
			},
		},
		CommitSHA: "test",
	}

	req := httptest.NewRequest(http.MethodGet, "/recommendations/categories", nil)
	req.Header.Set("X-Cove-Uid", "uid-no-interests")
	rr := httptest.NewRecorder()

	deps.RecommendedCategoriesHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", rr.Code)
	}

	var body recommendedCategoriesResponse
	if err := json.NewDecoder(rr.Body).Decode(&body); err != nil {
		t.Fatalf("decode body: %v", err)
	}
	if len(body.Categories) != 1 {
		t.Errorf("expected 1 fallback category, got %d", len(body.Categories))
	}
	if body.Categories[0].Name != "Pottery" {
		t.Errorf("category name: got %q, want %q", body.Categories[0].Name, "Pottery")
	}
	if queryCalls != 2 {
		t.Errorf("expected 2 query calls (interest + fallback), got %d", queryCalls)
	}
}

func TestRecommendedCategoriesHandler_BothQueriesEmpty(t *testing.T) {
	// Both queries return empty — response should be 200 with empty categories list.
	deps := &Deps{
		DB: &mockStore{
			queryFn: func(ctx context.Context, sql string, args ...any) (Rows, error) {
				return &emptyRows{}, nil
			},
		},
		CommitSHA: "test",
	}

	req := httptest.NewRequest(http.MethodGet, "/recommendations/categories", nil)
	req.Header.Set("X-Cove-Uid", "uid-empty")
	rr := httptest.NewRecorder()

	deps.RecommendedCategoriesHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", rr.Code)
	}

	var body recommendedCategoriesResponse
	if err := json.NewDecoder(rr.Body).Decode(&body); err != nil {
		t.Fatalf("decode body: %v", err)
	}
	if len(body.Categories) != 0 {
		t.Errorf("expected 0 categories, got %d", len(body.Categories))
	}
}
