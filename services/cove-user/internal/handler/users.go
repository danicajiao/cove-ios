package handler

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// ── User profile ──────────────────────────────────────────────────────────────

type userProfile struct {
	UID       string `json:"uid"`
	Username  string `json:"username"`
	Email     string `json:"email"`
	CreatedAt string `json:"created_at"`
}

// GetMeHandler handles GET /users/me.
// Returns 404 if the user doesn't exist in profile.users.
func (d *Deps) GetMeHandler(w http.ResponseWriter, r *http.Request) {
	uid := r.Header.Get("X-Cove-Uid")

	const q = `
SELECT uid, username, email, created_at::text
FROM profile.users
WHERE uid = $1`

	var u userProfile
	err := d.DB.QueryRow(r.Context(), q, uid).Scan(&u.UID, &u.Username, &u.Email, &u.CreatedAt)
	if err != nil {
		if isNotFound(err) {
			writeError(w, http.StatusNotFound, "user profile not found")
			return
		}
		log.Printf("ERROR GetMeHandler uid=%s: %v", uid, err)
		writeError(w, http.StatusInternalServerError, "profile query failed")
		return
	}

	writeJSON(w, http.StatusOK, u)
}

// ── Favorites ─────────────────────────────────────────────────────────────────

type favoriteItem struct {
	ItemID      string  `json:"item_id"`
	ItemName    string  `json:"item_name"`
	PriceCents  *int    `json:"price_cents,omitempty"`
	FavoritedAt string  `json:"favorited_at"`
}

type favoritesResponse struct {
	Favorites []favoriteItem `json:"favorites"`
	Total     int            `json:"total"`
}

// GetFavoritesHandler handles GET /users/me/favorites.
func (d *Deps) GetFavoritesHandler(w http.ResponseWriter, r *http.Request) {
	uid := r.Header.Get("X-Cove-Uid")

	if !d.userExists(r, uid) {
		writeError(w, http.StatusNotFound, "user profile not found")
		return
	}

	limit := 25
	offset := 0
	if v := r.URL.Query().Get("limit"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 && n <= 100 {
			limit = n
		}
	}
	if v := r.URL.Query().Get("offset"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n >= 0 {
			offset = n
		}
	}

	// Count total favorites.
	var total int
	err := d.DB.QueryRow(r.Context(),
		`SELECT COUNT(*) FROM profile.favorites WHERE uid = $1`, uid).Scan(&total)
	if err != nil {
		log.Printf("ERROR GetFavoritesHandler count uid=%s: %v", uid, err)
		writeError(w, http.StatusInternalServerError, "favorites query failed")
		return
	}

	const q = `
SELECT f.item_id, i.name, i.price_cents, f.created_at::text
FROM profile.favorites f
JOIN catalog.items i ON i.id = f.item_id
WHERE f.uid = $1
ORDER BY f.created_at DESC
LIMIT $2 OFFSET $3`

	rows, err := d.DB.Query(r.Context(), q, uid, limit, offset)
	if err != nil {
		log.Printf("ERROR GetFavoritesHandler query uid=%s: %v", uid, err)
		writeError(w, http.StatusInternalServerError, "favorites query failed")
		return
	}
	defer rows.Close()

	favorites := []favoriteItem{}
	for rows.Next() {
		var itemID pgtype.UUID
		var name string
		var priceCents *int32
		var favoritedAt string
		if err := rows.Scan(&itemID, &name, &priceCents, &favoritedAt); err != nil {
			log.Printf("ERROR GetFavoritesHandler scan uid=%s: %v", uid, err)
			writeError(w, http.StatusInternalServerError, "favorites scan failed")
			return
		}
		fi := favoriteItem{
			ItemID:      formatUUID(itemID),
			ItemName:    name,
			FavoritedAt: favoritedAt,
		}
		if priceCents != nil {
			v := int(*priceCents)
			fi.PriceCents = &v
		}
		favorites = append(favorites, fi)
	}
	if err := rows.Err(); err != nil {
		writeError(w, http.StatusInternalServerError, "favorites iteration failed")
		return
	}

	writeJSON(w, http.StatusOK, favoritesResponse{Favorites: favorites, Total: total})
}

// AddFavoriteHandler handles POST /users/me/favorites/{itemId}.
func (d *Deps) AddFavoriteHandler(w http.ResponseWriter, r *http.Request) {
	uid := r.Header.Get("X-Cove-Uid")
	itemID := chi.URLParam(r, "itemId")

	if !d.userExists(r, uid) {
		writeError(w, http.StatusNotFound, "user profile not found")
		return
	}

	const q = `
INSERT INTO profile.favorites (uid, item_id)
VALUES ($1, $2)
ON CONFLICT (uid, item_id) DO NOTHING`

	ct, err := d.DB.Exec(r.Context(), q, uid, itemID)
	if err != nil {
		log.Printf("ERROR AddFavoriteHandler uid=%s item=%s: %v", uid, itemID, err)
		writeError(w, http.StatusInternalServerError, "add favorite failed")
		return
	}
	if ct.RowsAffected() == 0 {
		writeError(w, http.StatusConflict, "item already favorited")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// RemoveFavoriteHandler handles DELETE /users/me/favorites/{itemId}.
func (d *Deps) RemoveFavoriteHandler(w http.ResponseWriter, r *http.Request) {
	uid := r.Header.Get("X-Cove-Uid")
	itemID := chi.URLParam(r, "itemId")

	const q = `DELETE FROM profile.favorites WHERE uid = $1 AND item_id = $2`

	ct, err := d.DB.Exec(r.Context(), q, uid, itemID)
	if err != nil {
		log.Printf("ERROR RemoveFavoriteHandler uid=%s item=%s: %v", uid, itemID, err)
		writeError(w, http.StatusInternalServerError, "remove favorite failed")
		return
	}
	if ct.RowsAffected() == 0 {
		writeError(w, http.StatusNotFound, "favorite not found")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// ── Follows ───────────────────────────────────────────────────────────────────

type follow struct {
	EntityType string `json:"entity_type"`
	EntityID   string `json:"entity_id"`
	EntityName string `json:"entity_name"`
	FollowedAt string `json:"followed_at"`
}

type followsResponse struct {
	Follows []follow `json:"follows"`
}

// GetFollowsHandler handles GET /users/me/follows.
func (d *Deps) GetFollowsHandler(w http.ResponseWriter, r *http.Request) {
	uid := r.Header.Get("X-Cove-Uid")

	if !d.userExists(r, uid) {
		writeError(w, http.StatusNotFound, "user profile not found")
		return
	}

	const q = `
SELECT 'maker' AS entity_type, m.id, m.name, f.created_at::text
FROM profile.follows f
JOIN directory.makers m ON m.id = f.maker_id
WHERE f.uid = $1 AND f.maker_id IS NOT NULL

UNION ALL

SELECT 'storefront' AS entity_type, s.id, s.name, f.created_at::text
FROM profile.follows f
JOIN directory.storefronts s ON s.id = f.storefront_id
WHERE f.uid = $1 AND f.storefront_id IS NOT NULL

ORDER BY 4 DESC`

	rows, err := d.DB.Query(r.Context(), q, uid)
	if err != nil {
		log.Printf("ERROR GetFollowsHandler uid=%s: %v", uid, err)
		writeError(w, http.StatusInternalServerError, "follows query failed")
		return
	}
	defer rows.Close()

	follows := []follow{}
	for rows.Next() {
		var entityType, entityName, followedAt string
		var entityID pgtype.UUID
		if err := rows.Scan(&entityType, &entityID, &entityName, &followedAt); err != nil {
			log.Printf("ERROR GetFollowsHandler scan uid=%s: %v", uid, err)
			writeError(w, http.StatusInternalServerError, "follows scan failed")
			return
		}
		follows = append(follows, follow{
			EntityType: entityType,
			EntityID:   formatUUID(entityID),
			EntityName: entityName,
			FollowedAt: followedAt,
		})
	}
	if err := rows.Err(); err != nil {
		writeError(w, http.StatusInternalServerError, "follows iteration failed")
		return
	}

	writeJSON(w, http.StatusOK, followsResponse{Follows: follows})
}

type addFollowRequest struct {
	MakerID      *string `json:"maker_id"`
	StorefrontID *string `json:"storefront_id"`
}

// AddFollowHandler handles POST /users/me/follows.
// profile.follows has no unique constraint — query before insert to detect duplicates.
func (d *Deps) AddFollowHandler(w http.ResponseWriter, r *http.Request) {
	uid := r.Header.Get("X-Cove-Uid")

	if !d.userExists(r, uid) {
		writeError(w, http.StatusNotFound, "user profile not found")
		return
	}

	var req addFollowRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if req.MakerID == nil && req.StorefrontID == nil {
		writeError(w, http.StatusBadRequest, "exactly one of maker_id or storefront_id must be provided")
		return
	}
	if req.MakerID != nil && req.StorefrontID != nil {
		writeError(w, http.StatusBadRequest, "exactly one of maker_id or storefront_id must be provided")
		return
	}

	if req.MakerID != nil {
		// Check for duplicate.
		var existing int
		err := d.DB.QueryRow(r.Context(),
			`SELECT COUNT(*) FROM profile.follows WHERE uid = $1 AND maker_id = $2`,
			uid, *req.MakerID).Scan(&existing)
		if err != nil {
			log.Printf("ERROR AddFollowHandler check maker uid=%s maker=%s: %v", uid, *req.MakerID, err)
			writeError(w, http.StatusInternalServerError, "follow check failed")
			return
		}
		if existing > 0 {
			writeError(w, http.StatusConflict, "already following")
			return
		}

		_, err = d.DB.Exec(r.Context(),
			`INSERT INTO profile.follows (uid, maker_id) VALUES ($1, $2)`,
			uid, *req.MakerID)
		if err != nil {
			log.Printf("ERROR AddFollowHandler insert maker uid=%s maker=%s: %v", uid, *req.MakerID, err)
			writeError(w, http.StatusInternalServerError, "add follow failed")
			return
		}
	} else {
		// Check for duplicate.
		var existing int
		err := d.DB.QueryRow(r.Context(),
			`SELECT COUNT(*) FROM profile.follows WHERE uid = $1 AND storefront_id = $2`,
			uid, *req.StorefrontID).Scan(&existing)
		if err != nil {
			log.Printf("ERROR AddFollowHandler check storefront uid=%s sf=%s: %v", uid, *req.StorefrontID, err)
			writeError(w, http.StatusInternalServerError, "follow check failed")
			return
		}
		if existing > 0 {
			writeError(w, http.StatusConflict, "already following")
			return
		}

		_, err = d.DB.Exec(r.Context(),
			`INSERT INTO profile.follows (uid, storefront_id) VALUES ($1, $2)`,
			uid, *req.StorefrontID)
		if err != nil {
			log.Printf("ERROR AddFollowHandler insert storefront uid=%s sf=%s: %v", uid, *req.StorefrontID, err)
			writeError(w, http.StatusInternalServerError, "add follow failed")
			return
		}
	}

	w.WriteHeader(http.StatusNoContent)
}

// RemoveFollowHandler handles DELETE /users/me/follows/{entityId}.
// Tries both maker_id and storefront_id columns.
func (d *Deps) RemoveFollowHandler(w http.ResponseWriter, r *http.Request) {
	uid := r.Header.Get("X-Cove-Uid")
	entityID := chi.URLParam(r, "entityId")

	// Try deleting as maker first, then as storefront.
	ct, err := d.DB.Exec(r.Context(),
		`DELETE FROM profile.follows WHERE uid = $1 AND maker_id = $2`,
		uid, entityID)
	if err != nil {
		log.Printf("ERROR RemoveFollowHandler maker uid=%s entity=%s: %v", uid, entityID, err)
		writeError(w, http.StatusInternalServerError, "remove follow failed")
		return
	}
	if ct.RowsAffected() > 0 {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	ct, err = d.DB.Exec(r.Context(),
		`DELETE FROM profile.follows WHERE uid = $1 AND storefront_id = $2`,
		uid, entityID)
	if err != nil {
		log.Printf("ERROR RemoveFollowHandler storefront uid=%s entity=%s: %v", uid, entityID, err)
		writeError(w, http.StatusInternalServerError, "remove follow failed")
		return
	}
	if ct.RowsAffected() == 0 {
		writeError(w, http.StatusNotFound, "follow not found")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// ── Interests ─────────────────────────────────────────────────────────────────

type interest struct {
	CategoryID   string `json:"category_id"`
	CategoryPath string `json:"category_path"`
	CategoryName string `json:"category_name"`
	CreatedAt    string `json:"created_at"`
}

type interestsResponse struct {
	Interests []interest `json:"interests"`
}

// GetInterestsHandler handles GET /users/me/interests.
func (d *Deps) GetInterestsHandler(w http.ResponseWriter, r *http.Request) {
	uid := r.Header.Get("X-Cove-Uid")

	if !d.userExists(r, uid) {
		writeError(w, http.StatusNotFound, "user profile not found")
		return
	}

	const q = `
SELECT i.category_id, c.path::text, c.name, i.created_at::text
FROM profile.interests i
JOIN catalog.categories c ON c.id = i.category_id
WHERE i.uid = $1
ORDER BY c.name`

	rows, err := d.DB.Query(r.Context(), q, uid)
	if err != nil {
		log.Printf("ERROR GetInterestsHandler uid=%s: %v", uid, err)
		writeError(w, http.StatusInternalServerError, "interests query failed")
		return
	}
	defer rows.Close()

	interests := []interest{}
	for rows.Next() {
		var categoryID pgtype.UUID
		var path, name, createdAt string
		if err := rows.Scan(&categoryID, &path, &name, &createdAt); err != nil {
			log.Printf("ERROR GetInterestsHandler scan uid=%s: %v", uid, err)
			writeError(w, http.StatusInternalServerError, "interests scan failed")
			return
		}
		interests = append(interests, interest{
			CategoryID:   formatUUID(categoryID),
			CategoryPath: path,
			CategoryName: name,
			CreatedAt:    createdAt,
		})
	}
	if err := rows.Err(); err != nil {
		writeError(w, http.StatusInternalServerError, "interests iteration failed")
		return
	}

	writeJSON(w, http.StatusOK, interestsResponse{Interests: interests})
}

type replaceInterestsRequest struct {
	CategoryIDs []string `json:"category_ids"`
}

// ReplaceInterestsHandler handles PUT /users/me/interests.
// Replaces the full interest set in a transaction: DELETE existing + INSERT new.
func (d *Deps) ReplaceInterestsHandler(w http.ResponseWriter, r *http.Request) {
	uid := r.Header.Get("X-Cove-Uid")

	if !d.userExists(r, uid) {
		writeError(w, http.StatusNotFound, "user profile not found")
		return
	}

	var req replaceInterestsRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if req.CategoryIDs == nil {
		writeError(w, http.StatusBadRequest, "category_ids is required")
		return
	}

	tx, err := d.DB.Begin(r.Context())
	if err != nil {
		log.Printf("ERROR ReplaceInterestsHandler begin tx uid=%s: %v", uid, err)
		writeError(w, http.StatusInternalServerError, "transaction failed")
		return
	}
	defer tx.Rollback(r.Context()) //nolint:errcheck

	if _, err := tx.Exec(r.Context(),
		`DELETE FROM profile.interests WHERE uid = $1`, uid); err != nil {
		log.Printf("ERROR ReplaceInterestsHandler delete uid=%s: %v", uid, err)
		writeError(w, http.StatusInternalServerError, "interests replace failed")
		return
	}

	for _, catID := range req.CategoryIDs {
		if _, err := tx.Exec(r.Context(),
			`INSERT INTO profile.interests (uid, category_id) VALUES ($1, $2)
			 ON CONFLICT (uid, category_id) DO NOTHING`,
			uid, catID); err != nil {
			log.Printf("ERROR ReplaceInterestsHandler insert uid=%s cat=%s: %v", uid, catID, err)
			writeError(w, http.StatusInternalServerError, "interests replace failed")
			return
		}
	}

	if err := tx.Commit(r.Context()); err != nil {
		log.Printf("ERROR ReplaceInterestsHandler commit uid=%s: %v", uid, err)
		writeError(w, http.StatusInternalServerError, "interests replace failed")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// ── Events ────────────────────────────────────────────────────────────────────

type ingestEventRequest struct {
	EventType  string          `json:"event_type"`
	CategoryID *string         `json:"category_id,omitempty"`
	ItemID     *string         `json:"item_id,omitempty"`
	Metadata   json.RawMessage `json:"metadata,omitempty"`
}

var validEventTypes = map[string]bool{
	"category_tap":  true,
	"item_view":     true,
	"result_dwell":  true,
	"search":        true,
}

// IngestEventHandler handles POST /users/me/events.
func (d *Deps) IngestEventHandler(w http.ResponseWriter, r *http.Request) {
	uid := r.Header.Get("X-Cove-Uid")

	if !d.userExists(r, uid) {
		writeError(w, http.StatusNotFound, "user profile not found")
		return
	}

	var req ingestEventRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if !validEventTypes[req.EventType] {
		writeError(w, http.StatusBadRequest, "event_type must be one of: category_tap, item_view, result_dwell, search")
		return
	}

	metadata := req.Metadata
	if metadata == nil {
		metadata = json.RawMessage(`{}`)
	}

	const q = `
INSERT INTO profile.events (uid, event_type, category_id, item_id, metadata)
VALUES ($1, $2, $3, $4, $5)`

	_, err := d.DB.Exec(r.Context(), q, uid, req.EventType, req.CategoryID, req.ItemID, metadata)
	if err != nil {
		log.Printf("ERROR IngestEventHandler uid=%s type=%s: %v", uid, req.EventType, err)
		writeError(w, http.StatusInternalServerError, "event ingest failed")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// ── Helpers ───────────────────────────────────────────────────────────────────

// userExists returns true if the uid has a row in profile.users.
// On DB error it writes a 500 and returns false.
func (d *Deps) userExists(r *http.Request, uid string) bool {
	var exists bool
	err := d.DB.QueryRow(r.Context(),
		`SELECT EXISTS(SELECT 1 FROM profile.users WHERE uid = $1)`, uid).Scan(&exists)
	if err != nil {
		log.Printf("ERROR userExists uid=%s: %v", uid, err)
		return false
	}
	return exists
}
