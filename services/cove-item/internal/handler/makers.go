package handler

import (
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// makerDetail is the GET /makers/:id response body.
type makerDetail struct {
	ID          string             `json:"id"`
	Name        string             `json:"name"`
	Description *string            `json:"description,omitempty"`
	Tier        string             `json:"tier"`
	TrustScore  float64            `json:"trust_score"`
	City        *string            `json:"city,omitempty"`
	State       *string            `json:"state,omitempty"`
	WebsiteURL  *string            `json:"website_url,omitempty"`
	Signals     []Signal           `json:"signals"`
	Storefronts []makerStorefront  `json:"storefronts"`
}

type makerStorefront struct {
	ID   string `json:"id"`
	Name string `json:"name"`
	Type string `json:"type"`
	Slug string `json:"slug,omitempty"`
}

// MakerHandler handles GET /makers/{id}.
// Returns maker detail with signals and associated storefront list.
func (d *Deps) MakerHandler(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if id == "" {
		writeError(w, http.StatusBadRequest, "missing maker id")
		return
	}

	// ── Core maker ───────────────────────────────────────────────────────────
	const makerSQL = `
SELECT id, name, description, tier, trust_score, city, state, website_url
FROM   directory.makers
WHERE  id = $1 AND is_active`

	var (
		makerID    pgtype.UUID
		name, tier string
		description, city, state, websiteURL *string
		trustScore float64
	)
	err := d.DB.QueryRow(r.Context(), makerSQL, id).Scan(
		&makerID, &name, &description, &tier, &trustScore,
		&city, &state, &websiteURL,
	)
	if err != nil {
		if isNotFound(err) {
			writeError(w, http.StatusNotFound, "maker not found")
			return
		}
		log.Printf("ERROR maker query id=%s: %v", id, err)
		writeError(w, http.StatusInternalServerError, "maker query failed")
		return
	}

	// ── Signals ──────────────────────────────────────────────────────────────
	const signalsSQL = `
SELECT s.code, s.name, s.description, s.weight, es.status, es.verified_at, es.cert_number
FROM   catalog.entity_signals es
JOIN   catalog.signals s ON s.id = es.signal_id
WHERE  es.maker_id = $1 AND s.is_active
ORDER  BY s.weight DESC, s.name`

	signals, err := querySignals(d, r, signalsSQL, id)
	if err != nil {
		log.Printf("ERROR maker signals id=%s: %v", id, err)
		writeError(w, http.StatusInternalServerError, "signals query failed")
		return
	}

	// ── Storefronts ──────────────────────────────────────────────────────────
	const storefrontsSQL = `
SELECT id, name, type, coalesce(slug, '')
FROM   directory.storefronts
WHERE  operated_by_maker_id = $1 AND is_active
ORDER  BY name`

	sfRows, err := d.DB.Query(r.Context(), storefrontsSQL, id)
	if err != nil {
		log.Printf("ERROR maker storefronts id=%s: %v", id, err)
		writeError(w, http.StatusInternalServerError, "storefronts query failed")
		return
	}
	defer sfRows.Close()

	var storefronts []makerStorefront
	for sfRows.Next() {
		var sfID pgtype.UUID
		var sfName, sfType, sfSlug string
		if err := sfRows.Scan(&sfID, &sfName, &sfType, &sfSlug); err != nil {
			log.Printf("ERROR maker storefronts scan id=%s: %v", id, err)
			writeError(w, http.StatusInternalServerError, "storefronts scan failed")
			return
		}
		storefronts = append(storefronts, makerStorefront{
			ID:   formatUUID(sfID),
			Name: sfName,
			Type: sfType,
			Slug: sfSlug,
		})
	}
	if err := sfRows.Err(); err != nil {
		writeError(w, http.StatusInternalServerError, "storefronts iteration failed")
		return
	}

	writeJSON(w, http.StatusOK, makerDetail{
		ID:          formatUUID(makerID),
		Name:        name,
		Description: description,
		Tier:        tier,
		TrustScore:  trustScore,
		City:        city,
		State:       state,
		WebsiteURL:  websiteURL,
		Signals:     signals,
		Storefronts: storefronts,
	})
}
