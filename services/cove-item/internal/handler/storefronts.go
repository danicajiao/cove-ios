package handler

import (
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// storefrontDetailFull is the GET /storefronts/:id response body.
type storefrontDetailFull struct {
	ID          string            `json:"id"`
	Name        string            `json:"name"`
	Description *string           `json:"description,omitempty"`
	Type        string            `json:"type"`
	TrustScore  float64           `json:"trust_score"`
	City        *string           `json:"city,omitempty"`
	State       *string           `json:"state,omitempty"`
	Address     *string           `json:"address,omitempty"`
	WebsiteURL  *string           `json:"website_url,omitempty"`
	MakerID     string            `json:"maker_id,omitempty"`
	MakerName   string            `json:"maker_name,omitempty"`
	Signals     []Signal          `json:"signals"`
	Items       []storefrontItem  `json:"items"`
}

type storefrontItem struct {
	ID         string         `json:"id"`
	Name       string         `json:"name"`
	PriceCents *int           `json:"price_cents,omitempty"`
	ListingURL *string        `json:"listing_url,omitempty"`
	Image      *ImageVariants `json:"image,omitempty"`
}

// StorefrontHandler handles GET /storefronts/{id}.
// Returns storefront detail with signals and list of available items.
func (d *Deps) StorefrontHandler(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if id == "" {
		writeError(w, http.StatusBadRequest, "missing storefront id")
		return
	}

	// ── Core storefront + maker ───────────────────────────────────────────────
	const sfSQL = `
SELECT
    s.id, s.name, s.description, s.type, s.trust_score,
    s.city, s.state, s.address, s.website_url,
    m.id AS maker_id, m.name AS maker_name
FROM directory.storefronts  s
LEFT JOIN directory.makers  m ON m.id = s.operated_by_maker_id
WHERE s.id = $1 AND s.is_active`

	var (
		sfID                                pgtype.UUID
		sfName, sfType                      string
		sfDesc, sfCity, sfState, sfAddr, sfURL *string
		trustScore                          float64
		makerID                             pgtype.UUID
		makerName                           *string
	)
	err := d.DB.QueryRow(r.Context(), sfSQL, id).Scan(
		&sfID, &sfName, &sfDesc, &sfType, &trustScore,
		&sfCity, &sfState, &sfAddr, &sfURL,
		&makerID, &makerName,
	)
	if err != nil {
		if isNotFound(err) {
			writeError(w, http.StatusNotFound, "storefront not found")
			return
		}
		log.Printf("ERROR storefront query id=%s: %v", id, err)
		writeError(w, http.StatusInternalServerError, "storefront query failed")
		return
	}

	// ── Signals ──────────────────────────────────────────────────────────────
	const signalsSQL = `
SELECT s.code, s.name, s.description, s.weight, es.status, es.verified_at, es.cert_number
FROM   catalog.entity_signals es
JOIN   catalog.signals s ON s.id = es.signal_id
WHERE  es.storefront_id = $1 AND s.is_active
ORDER  BY s.weight DESC, s.name`

	signals, err := querySignals(d, r, signalsSQL, id)
	if err != nil {
		log.Printf("ERROR storefront signals id=%s: %v", id, err)
		writeError(w, http.StatusInternalServerError, "signals query failed")
		return
	}

	// ── Items available at this storefront ───────────────────────────────────
	const itemsSQL = `
SELECT
    p.id, p.name, p.price_cents,
    a.listing_url,
    img.media_key, img.width, img.height
FROM catalog.availability a
JOIN catalog.items        p   ON p.id = a.item_id
LEFT JOIN LATERAL (
    SELECT media_key, width, height
    FROM   catalog.media
    WHERE  item_id = p.id AND role = 'primary'
    LIMIT  1
) img ON TRUE
WHERE a.storefront_id = $1 AND a.is_active AND p.is_active
ORDER BY p.name`

	itemRows, err := d.DB.Query(r.Context(), itemsSQL, id)
	if err != nil {
		log.Printf("ERROR storefront items id=%s: %v", id, err)
		writeError(w, http.StatusInternalServerError, "items query failed")
		return
	}
	defer itemRows.Close()

	var items []storefrontItem
	for itemRows.Next() {
		var itemID pgtype.UUID
		var itemName string
		var priceCents *int32
		var listingURL, mediaKey *string
		var imgWidth, imgHeight *int32

		if err := itemRows.Scan(&itemID, &itemName, &priceCents, &listingURL,
			&mediaKey, &imgWidth, &imgHeight); err != nil {
			log.Printf("ERROR storefront items scan id=%s: %v", id, err)
			writeError(w, http.StatusInternalServerError, "items scan failed")
			return
		}

		var pc *int
		if priceCents != nil {
			v := int(*priceCents)
			pc = &v
		}

		var img *ImageVariants
		if mediaKey != nil && *mediaKey != "" {
			w2, h2 := 0, 0
			if imgWidth != nil {
				w2 = int(*imgWidth)
			}
			if imgHeight != nil {
				h2 = int(*imgHeight)
			}
			img = d.signListVariants(*mediaKey, w2, h2)
		}

		items = append(items, storefrontItem{
			ID:         formatUUID(itemID),
			Name:       itemName,
			PriceCents: pc,
			ListingURL: listingURL,
			Image:      img,
		})
	}
	if err := itemRows.Err(); err != nil {
		writeError(w, http.StatusInternalServerError, "items iteration failed")
		return
	}

	// ── Assemble response ────────────────────────────────────────────────────
	makerIDStr := ""
	makerNameStr := ""
	if makerID.Valid {
		makerIDStr = formatUUID(makerID)
	}
	if makerName != nil {
		makerNameStr = *makerName
	}

	writeJSON(w, http.StatusOK, storefrontDetailFull{
		ID:          formatUUID(sfID),
		Name:        sfName,
		Description: sfDesc,
		Type:        sfType,
		TrustScore:  trustScore,
		City:        sfCity,
		State:       sfState,
		Address:     sfAddr,
		WebsiteURL:  sfURL,
		MakerID:     makerIDStr,
		MakerName:   makerNameStr,
		Signals:     signals,
		Items:       items,
	})
}
