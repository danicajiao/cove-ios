package handler

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// itemDetail is the GET /items/:id response body.
type itemDetail struct {
	ID          string             `json:"id"`
	Name        string             `json:"name"`
	Description *string            `json:"description,omitempty"`
	PriceCents  *int               `json:"price_cents,omitempty"`
	Attributes  json.RawMessage    `json:"attributes,omitempty"`
	Details     json.RawMessage    `json:"details,omitempty"`
	CategoryID  string             `json:"category_id"`
	Maker       makerSummary       `json:"maker"`
	Signals     []Signal           `json:"signals"`
	Storefronts []storefrontDetail `json:"storefronts"`
	Media       []ItemMedia        `json:"media"`
}

type storefrontDetail struct {
	ID         string   `json:"id"`
	Name       string   `json:"name"`
	Type       string   `json:"type"`
	ListingURL *string  `json:"listing_url,omitempty"`
}

// ItemHandler handles GET /items/{id}.
// Returns full item detail: signals (item + maker + storefront), all
// storefronts, and signed imgproxy URLs for all five media variants.
func (d *Deps) ItemHandler(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if id == "" {
		writeError(w, http.StatusBadRequest, "missing item id")
		return
	}

	// ── Core item + maker ────────────────────────────────────────────────────
	const itemSQL = `
SELECT
    p.id, p.name, p.description, p.price_cents,
    p.attributes, p.details, p.category_id::text,
    m.id AS maker_id, m.name AS maker_name, m.trust_score
FROM catalog.items p
JOIN directory.makers m ON m.id = p.maker_id
WHERE p.id = $1 AND p.is_active`

	var (
		itemID, makerID     pgtype.UUID
		itemName, makerName string
		description         *string
		priceCents          *int32
		attributes, details []byte
		categoryID          string
		makerTrust          float64
	)
	err := d.DB.QueryRow(r.Context(), itemSQL, id).Scan(
		&itemID, &itemName, &description, &priceCents,
		&attributes, &details, &categoryID,
		&makerID, &makerName, &makerTrust,
	)
	if err != nil {
		if isNotFound(err) {
			writeError(w, http.StatusNotFound, "item not found")
			return
		}
		log.Printf("ERROR item query id=%s: %v", id, err)
		writeError(w, http.StatusInternalServerError, "item query failed")
		return
	}

	// ── Signals: item + maker + storefronts that carry this item ─────────────
	const signalsSQL = `
SELECT scope, code, name, description, weight, status, verified_at, cert_number
FROM (
    SELECT 'item'        AS scope, s.code, s.name, s.description, s.weight,
           es.status, es.verified_at, es.cert_number
    FROM catalog.entity_signals es
    JOIN catalog.signals s ON s.id = es.signal_id
    WHERE es.item_id = $1 AND s.is_active

    UNION ALL

    SELECT 'maker'       AS scope, s.code, s.name, s.description, s.weight,
           es.status, es.verified_at, es.cert_number
    FROM catalog.entity_signals es
    JOIN catalog.signals s ON s.id = es.signal_id
    JOIN catalog.items   i ON i.maker_id = es.maker_id
    WHERE i.id = $1 AND s.is_active

    UNION ALL

    SELECT 'storefront'  AS scope, s.code, s.name, s.description, s.weight,
           es.status, es.verified_at, es.cert_number
    FROM catalog.entity_signals es
    JOIN catalog.signals        s ON s.id = es.signal_id
    JOIN catalog.availability   a ON a.storefront_id = es.storefront_id
    WHERE a.item_id = $1 AND a.is_active AND s.is_active
) combined
ORDER BY weight DESC, name`

	sigRows, err := d.DB.Query(r.Context(), signalsSQL, id)
	if err != nil {
		log.Printf("ERROR signals query item=%s: %v", id, err)
		writeError(w, http.StatusInternalServerError, "signals query failed")
		return
	}
	defer sigRows.Close()

	var signals []Signal
	for sigRows.Next() {
		var scope, code, name string
		var description *string
		var weight float64
		var status string
		var verifiedAt *string
		var certNumber *string
		if err := sigRows.Scan(&scope, &code, &name, &description, &weight,
			&status, &verifiedAt, &certNumber); err != nil {
			log.Printf("ERROR signals scan item=%s: %v", id, err)
			writeError(w, http.StatusInternalServerError, "signals scan failed")
			return
		}
		signals = append(signals, Signal{
			Code:        code,
			Name:        name,
			Description: description,
			Weight:      weight,
			Status:      status,
			VerifiedAt:  verifiedAt,
			CertNumber:  certNumber,
		})
	}
	if err := sigRows.Err(); err != nil {
		writeError(w, http.StatusInternalServerError, "signals iteration failed")
		return
	}

	// ── Storefronts ──────────────────────────────────────────────────────────
	const storefrontsSQL = `
SELECT s.id, s.name, s.type, a.listing_url
FROM catalog.availability   a
JOIN directory.storefronts  s ON s.id = a.storefront_id
WHERE a.item_id = $1 AND a.is_active AND s.is_active
ORDER BY s.name`

	sfRows, err := d.DB.Query(r.Context(), storefrontsSQL, id)
	if err != nil {
		log.Printf("ERROR storefronts query item=%s: %v", id, err)
		writeError(w, http.StatusInternalServerError, "storefronts query failed")
		return
	}
	defer sfRows.Close()

	var storefronts []storefrontDetail
	for sfRows.Next() {
		var sfID pgtype.UUID
		var sfName, sfType string
		var listingURL *string
		if err := sfRows.Scan(&sfID, &sfName, &sfType, &listingURL); err != nil {
			log.Printf("ERROR storefronts scan item=%s: %v", id, err)
			writeError(w, http.StatusInternalServerError, "storefronts scan failed")
			return
		}
		storefronts = append(storefronts, storefrontDetail{
			ID:         formatUUID(sfID),
			Name:       sfName,
			Type:       sfType,
			ListingURL: listingURL,
		})
	}
	if err := sfRows.Err(); err != nil {
		writeError(w, http.StatusInternalServerError, "storefronts iteration failed")
		return
	}

	// ── Media ────────────────────────────────────────────────────────────────
	const mediaSQL = `
SELECT media_key, role, coalesce(alt_text, ''), width, height
FROM   catalog.media
WHERE  item_id = $1
ORDER  BY sort_order`

	medRows, err := d.DB.Query(r.Context(), mediaSQL, id)
	if err != nil {
		log.Printf("ERROR media query item=%s: %v", id, err)
		writeError(w, http.StatusInternalServerError, "media query failed")
		return
	}
	defer medRows.Close()

	var media []ItemMedia
	for medRows.Next() {
		var mediaKey, role, altText string
		var width, height int32
		if err := medRows.Scan(&mediaKey, &role, &altText, &width, &height); err != nil {
			log.Printf("ERROR media scan item=%s: %v", id, err)
			writeError(w, http.StatusInternalServerError, "media scan failed")
			return
		}
		media = append(media, d.signAllVariants(mediaKey, role, altText, int(width), int(height)))
	}
	if err := medRows.Err(); err != nil {
		writeError(w, http.StatusInternalServerError, "media iteration failed")
		return
	}

	// ── Assemble response ────────────────────────────────────────────────────
	var pc *int
	if priceCents != nil {
		v := int(*priceCents)
		pc = &v
	}

	detail := itemDetail{
		ID:          formatUUID(itemID),
		Name:        itemName,
		Description: description,
		PriceCents:  pc,
		Attributes:  attributes,
		Details:     details,
		CategoryID:  categoryID,
		Maker: makerSummary{
			ID:         formatUUID(makerID),
			Name:       makerName,
			TrustScore: makerTrust,
		},
		Signals:     signals,
		Storefronts: storefronts,
		Media:       media,
	}

	writeJSON(w, http.StatusOK, detail)
}
