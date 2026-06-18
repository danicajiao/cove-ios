package handler

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/jackc/pgx/v5/pgtype"
)

// discoveryResult is one item in the GET /discovery response.
type discoveryResult struct {
	ID                string             `json:"id"`
	Name              string             `json:"name"`
	Description       *string            `json:"description,omitempty"`
	PriceCents        *int               `json:"price_cents,omitempty"`
	Maker             makerSummary       `json:"maker"`
	NearestStorefront storefrontSummary  `json:"nearest_storefront"`
	Storefronts       []storefrontSummary `json:"storefronts"`
	PrimaryImage      *ImageVariants     `json:"primary_image,omitempty"`
	BaseTrust         float64            `json:"base_trust"`
	Score             float64            `json:"score"`
}

type makerSummary struct {
	ID         string  `json:"id"`
	Name       string  `json:"name"`
	TrustScore float64 `json:"trust_score"`
}

type storefrontSummary struct {
	ID         string   `json:"id"`
	Name       string   `json:"name"`
	Type       string   `json:"type"`
	DistanceM  *float64 `json:"distance_m,omitempty"`
	ListingURL *string  `json:"listing_url,omitempty"`
}

// DiscoveryHandler handles GET /discovery.
//
// Query params (all optional):
//   - q        — free-text search term
//   - lat, lon — decimal-degree coordinates; must appear together
//   - radius   — search radius in metres (default 50 000 when lat/lon provided)
//   - category — ltree path; scopes results to that subtree (e.g. "food.coffee")
func (d *Deps) DiscoveryHandler(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query().Get("q")
	latStr := r.URL.Query().Get("lat")
	lonStr := r.URL.Query().Get("lon")
	radiusStr := r.URL.Query().Get("radius")
	category := r.URL.Query().Get("category")

	var lat, lon, radiusM *float64
	if latStr != "" || lonStr != "" {
		if latStr == "" || lonStr == "" {
			writeError(w, http.StatusBadRequest, "lat and lon must be provided together")
			return
		}
		la, err1 := strconv.ParseFloat(latStr, 64)
		lo, err2 := strconv.ParseFloat(lonStr, 64)
		if err1 != nil || err2 != nil {
			writeError(w, http.StatusBadRequest, "lat and lon must be valid decimal numbers")
			return
		}
		lat = &la
		lon = &lo

		defaultRadius := 50_000.0 // 50 km
		if radiusStr != "" {
			rm, err := strconv.ParseFloat(radiusStr, 64)
			if err != nil || rm <= 0 {
				writeError(w, http.StatusBadRequest, "radius must be a positive number (metres)")
				return
			}
			defaultRadius = rm
		}
		radiusM = &defaultRadius
	}

	sql, args := buildDiscoverySQL(q, lat, lon, radiusM, category)

	rows, err := d.DB.Query(r.Context(), sql, args...)
	if err != nil {
		log.Printf("ERROR discovery query: %v", err)
		writeError(w, http.StatusInternalServerError, "discovery query failed")
		return
	}
	defer rows.Close()

	type rawRow struct {
		itemID          pgtype.UUID
		itemName        string
		description     *string
		priceCents      *int32
		makerID         pgtype.UUID
		makerName       string
		makerTrustScore float64
		sfID            pgtype.UUID
		sfName          string
		sfType          string
		sfListingURL    *string
		distanceM       *float64
		baseTrust       float64
		score           float64
		mediaKey        *string
		imgWidth        *int32
		imgHeight       *int32
	}

	var raws []rawRow
	itemIDs := make([]pgtype.UUID, 0, 25)

	for rows.Next() {
		var rw rawRow
		if err := rows.Scan(
			&rw.itemID, &rw.itemName, &rw.description, &rw.priceCents,
			&rw.makerID, &rw.makerName, &rw.makerTrustScore,
			&rw.sfID, &rw.sfName, &rw.sfType, &rw.sfListingURL,
			&rw.distanceM, &rw.baseTrust, &rw.score,
			&rw.mediaKey, &rw.imgWidth, &rw.imgHeight,
		); err != nil {
			log.Printf("ERROR discovery scan: %v", err)
			writeError(w, http.StatusInternalServerError, "result scan failed")
			return
		}
		raws = append(raws, rw)
		itemIDs = append(itemIDs, rw.itemID)
	}
	if err := rows.Err(); err != nil {
		log.Printf("ERROR discovery rows: %v", err)
		writeError(w, http.StatusInternalServerError, "result iteration failed")
		return
	}

	if len(raws) == 0 {
		writeJSON(w, http.StatusOK, map[string]any{"results": []any{}})
		return
	}

	sfMap, err := fetchStorefrontsForItems(r.Context(), d, itemIDs, lat, lon)
	if err != nil {
		log.Printf("ERROR fetching storefronts: %v", err)
		writeError(w, http.StatusInternalServerError, "storefront query failed")
		return
	}

	results := make([]discoveryResult, 0, len(raws))
	for _, rw := range raws {
		itemIDStr := formatUUID(rw.itemID)

		var priceCents *int
		if rw.priceCents != nil {
			pc := int(*rw.priceCents)
			priceCents = &pc
		}

		var primaryImage *ImageVariants
		if rw.mediaKey != nil && *rw.mediaKey != "" {
			w2, h2 := 0, 0
			if rw.imgWidth != nil {
				w2 = int(*rw.imgWidth)
			}
			if rw.imgHeight != nil {
				h2 = int(*rw.imgHeight)
			}
			primaryImage = d.signListVariants(*rw.mediaKey, w2, h2)
		}

		results = append(results, discoveryResult{
			ID:          itemIDStr,
			Name:        rw.itemName,
			Description: rw.description,
			PriceCents:  priceCents,
			Maker: makerSummary{
				ID:         formatUUID(rw.makerID),
				Name:       rw.makerName,
				TrustScore: rw.makerTrustScore,
			},
			NearestStorefront: storefrontSummary{
				ID:         formatUUID(rw.sfID),
				Name:       rw.sfName,
				Type:       rw.sfType,
				DistanceM:  rw.distanceM,
				ListingURL: rw.sfListingURL,
			},
			Storefronts:  sfMap[itemIDStr],
			PrimaryImage: primaryImage,
			BaseTrust:    rw.baseTrust,
			Score:        rw.score,
		})
	}

	writeJSON(w, http.StatusOK, map[string]any{"results": results})
}

// buildDiscoverySQL constructs the discovery SELECT and its bound arguments.
// All parameters except the active flags are optional; the query degrades
// gracefully when none of q / geo / category are supplied (returns all active
// items ranked by trust score).
func buildDiscoverySQL(q string, lat, lon, radiusM *float64, category string) (string, []any) {
	var args []any
	n := 0
	bind := func(v any) string {
		args = append(args, v)
		n++
		return fmt.Sprintf("$%d", n)
	}

	hasGeo := lat != nil && lon != nil && radiusM != nil
	hasQ := q != ""
	hasCat := category != ""

	// Bind all parameters upfront so we can reference the same placeholder
	// in both SELECT and WHERE without repeating the value.
	var qRef, lonRef, latRef, radiusRef, catRef string
	if hasQ {
		qRef = bind(q)
	}
	if hasGeo {
		lonRef = bind(*lon)
		latRef = bind(*lat)
		radiusRef = bind(*radiusM)
	}
	if hasCat {
		catRef = bind(category)
	}

	// Geography point expression used in both score and WHERE.
	var geoPoint string
	if hasGeo {
		geoPoint = fmt.Sprintf("ST_Point(%s, %s)::geography", lonRef, latRef)
	}

	// Blended score: trust 40 %, relevance 30 %, proximity 30 %.
	var scoreParts []string
	scoreParts = append(scoreParts, "0.40 * (m.trust_score + s.trust_score)")
	if hasQ {
		scoreParts = append(scoreParts,
			fmt.Sprintf("0.30 * ts_rank(p.search_vec, websearch_to_tsquery('english', %s))", qRef))
	}
	if hasGeo {
		scoreParts = append(scoreParts,
			fmt.Sprintf("0.30 * (1.0 / (1 + ST_Distance(s.location, %s)))", geoPoint))
	}
	scoreExpr := strings.Join(scoreParts, "\n            + ")

	// Distance column expression — NULL for non-geo queries.
	distanceExpr := "NULL::double precision"
	if hasGeo {
		distanceExpr = fmt.Sprintf("ST_Distance(s.location, %s)", geoPoint)
	}

	// WHERE predicates.
	var where []string
	where = append(where, "p.is_active", "m.is_active", "a.is_active", "s.is_active")
	if hasQ {
		where = append(where, fmt.Sprintf(
			"p.search_vec @@ websearch_to_tsquery('english', %s)", qRef))
	}
	if hasGeo {
		where = append(where, fmt.Sprintf(
			"ST_DWithin(s.location, %s, %s)", geoPoint, radiusRef))
	}
	if hasCat {
		where = append(where, fmt.Sprintf(
			"p.category_id IN (SELECT id FROM catalog.categories WHERE path <@ %s::ltree)", catRef))
	}
	whereClause := strings.Join(where, "\n      AND ")

	sql := fmt.Sprintf(`
WITH ranked AS (
    SELECT DISTINCT ON (p.id)
        p.id,
        p.name,
        p.description,
        p.price_cents,
        m.id                                AS maker_id,
        m.name                              AS maker_name,
        m.trust_score                       AS maker_trust_score,
        s.id                                AS sf_id,
        s.name                              AS sf_name,
        s.type                              AS sf_type,
        a.listing_url                       AS sf_listing_url,
        %s                                  AS distance_m,
        (m.trust_score + s.trust_score)     AS base_trust,
        (%s)                                AS score,
        img.media_key,
        img.width                           AS img_width,
        img.height                          AS img_height
    FROM catalog.items        p
    JOIN directory.makers     m   ON m.id = p.maker_id
    JOIN catalog.availability a   ON a.item_id = p.id
    JOIN directory.storefronts s  ON s.id = a.storefront_id
    LEFT JOIN LATERAL (
        SELECT media_key, width, height
        FROM   catalog.media
        WHERE  item_id = p.id AND role = 'primary'
        LIMIT  1
    ) img ON TRUE
    WHERE %s
    ORDER BY p.id, (%s) DESC
)
SELECT
    id, name, description, price_cents,
    maker_id, maker_name, maker_trust_score,
    sf_id, sf_name, sf_type, sf_listing_url,
    distance_m, base_trust, score,
    media_key, img_width, img_height
FROM ranked
ORDER BY score DESC
LIMIT 25`,
		distanceExpr,
		scoreExpr,
		whereClause,
		scoreExpr,
	)

	return sql, args
}

// fetchStorefrontsForItems returns a map of itemID string → []storefrontSummary
// for all active storefronts stocking any of the given items.
func fetchStorefrontsForItems(ctx context.Context, d *Deps, itemIDs []pgtype.UUID, lat, lon *float64) (map[string][]storefrontSummary, error) {
	if len(itemIDs) == 0 {
		return nil, nil
	}

	var args []any
	args = append(args, itemIDs)

	var distanceExpr string
	if lat != nil && lon != nil {
		distanceExpr = "ST_Distance(s.location, ST_Point($2, $3)::geography)"
		args = append(args, *lon, *lat)
	} else {
		distanceExpr = "NULL::double precision"
	}

	sql := fmt.Sprintf(`
SELECT
    a.item_id,
    s.id,
    s.name,
    s.type,
    a.listing_url,
    %s AS distance_m
FROM catalog.availability   a
JOIN directory.storefronts  s ON s.id = a.storefront_id
WHERE a.item_id = ANY($1)
  AND a.is_active
  AND s.is_active
ORDER BY a.item_id, distance_m NULLS LAST`, distanceExpr)

	rows, err := d.DB.Query(ctx, sql, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	result := make(map[string][]storefrontSummary)
	for rows.Next() {
		var itemID, sfID pgtype.UUID
		var sfName, sfType string
		var listingURL *string
		var distM *float64

		if err := rows.Scan(&itemID, &sfID, &sfName, &sfType, &listingURL, &distM); err != nil {
			return nil, err
		}
		key := formatUUID(itemID)
		result[key] = append(result[key], storefrontSummary{
			ID:         formatUUID(sfID),
			Name:       sfName,
			Type:       sfType,
			DistanceM:  distM,
			ListingURL: listingURL,
		})
	}
	return result, rows.Err()
}
