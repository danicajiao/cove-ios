package handler

import (
	"log"
	"net/http"

	"github.com/jackc/pgx/v5/pgtype"
)

type recommendedCategory struct {
	ID   string `json:"id"`
	Name string `json:"name"`
	Path string `json:"path"`
}

type recommendedCategoriesResponse struct {
	Categories []recommendedCategory `json:"categories"`
}

// RecommendedCategoriesHandler handles GET /recommendations/categories.
//
// Algorithm:
//  1. If the user has interests, return those categories ordered by engagement
//     count in profile.events (last 30 days) descending.
//  2. If the user has no interests, fall back to all leaf categories ordered by
//     total event count across all users (last 30 days) descending.
//  3. If no events at all, the ORDER BY COALESCE(engagement, 0) clause
//     naturally falls back to alphabetical by name.
func (d *Deps) RecommendedCategoriesHandler(w http.ResponseWriter, r *http.Request) {
	uid := r.Header.Get("X-Cove-Uid")

	// ── Query 1: interest-based personalization ──────────────────────────────
	const interestSQL = `
SELECT c.id, c.name, c.path::text
FROM profile.interests i
JOIN catalog.categories c ON c.id = i.category_id
LEFT JOIN (
    SELECT category_id, COUNT(*) AS engagement
    FROM profile.events
    WHERE uid = $1
      AND category_id IS NOT NULL
      AND created_at > now() - interval '30 days'
    GROUP BY category_id
) e ON e.category_id = i.category_id
WHERE i.uid = $1
ORDER BY COALESCE(e.engagement, 0) DESC, c.name ASC`

	rows, err := d.DB.Query(r.Context(), interestSQL, uid)
	if err != nil {
		log.Printf("ERROR RecommendedCategoriesHandler interest query uid=%s: %v", uid, err)
		writeError(w, http.StatusInternalServerError, "recommendations query failed")
		return
	}
	defer rows.Close()

	categories := []recommendedCategory{}
	for rows.Next() {
		var id pgtype.UUID
		var name, path string
		if err := rows.Scan(&id, &name, &path); err != nil {
			log.Printf("ERROR RecommendedCategoriesHandler interest scan uid=%s: %v", uid, err)
			writeError(w, http.StatusInternalServerError, "recommendations scan failed")
			return
		}
		categories = append(categories, recommendedCategory{
			ID:   formatUUID(id),
			Name: name,
			Path: path,
		})
	}
	if err := rows.Err(); err != nil {
		writeError(w, http.StatusInternalServerError, "recommendations iteration failed")
		return
	}

	// If the user has interests, return them.
	if len(categories) > 0 {
		writeJSON(w, http.StatusOK, recommendedCategoriesResponse{Categories: categories})
		return
	}

	// ── Query 2: global fallback (no interests) ───────────────────────────────
	const fallbackSQL = `
SELECT c.id, c.name, c.path::text
FROM catalog.categories c
LEFT JOIN (
    SELECT category_id, COUNT(*) AS engagement
    FROM profile.events
    WHERE category_id IS NOT NULL
      AND created_at > now() - interval '30 days'
    GROUP BY category_id
) e ON e.category_id = c.id
WHERE c.is_leaf = true
ORDER BY COALESCE(e.engagement, 0) DESC, c.name ASC`

	fallbackRows, err := d.DB.Query(r.Context(), fallbackSQL)
	if err != nil {
		log.Printf("ERROR RecommendedCategoriesHandler fallback query uid=%s: %v", uid, err)
		writeError(w, http.StatusInternalServerError, "recommendations query failed")
		return
	}
	defer fallbackRows.Close()

	for fallbackRows.Next() {
		var id pgtype.UUID
		var name, path string
		if err := fallbackRows.Scan(&id, &name, &path); err != nil {
			log.Printf("ERROR RecommendedCategoriesHandler fallback scan uid=%s: %v", uid, err)
			writeError(w, http.StatusInternalServerError, "recommendations scan failed")
			return
		}
		categories = append(categories, recommendedCategory{
			ID:   formatUUID(id),
			Name: name,
			Path: path,
		})
	}
	if err := fallbackRows.Err(); err != nil {
		writeError(w, http.StatusInternalServerError, "recommendations iteration failed")
		return
	}

	writeJSON(w, http.StatusOK, recommendedCategoriesResponse{Categories: categories})
}
