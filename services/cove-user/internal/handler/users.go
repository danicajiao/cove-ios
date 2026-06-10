package handler

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// ── User profile ──────────────────────────────────────────────────────────────

type userProfile struct {
	UID       string    `json:"uid"`       // auth_uid — Firebase UID exposed as "uid" for API compatibility
	Username  string    `json:"username"`
	CreatedAt time.Time `json:"created_at"`
}

// GetMeHandler handles GET /users/me.
// Returns 404 if the user doesn't exist in profile.users.
func (d *Deps) GetMeHandler(w http.ResponseWriter, r *http.Request) {
	authUID := r.Header.Get("X-Cove-Uid")

	const q = `
SELECT auth_uid, username, created_at
FROM profile.users
WHERE auth_uid = $1`

	var u userProfile
	err := d.DB.QueryRow(r.Context(), q, authUID).Scan(&u.UID, &u.Username, &u.CreatedAt)
	if err != nil {
		if isNotFound(err) {
			writeError(w, http.StatusNotFound, "user profile not found")
			return
		}
		log.Printf("ERROR GetMeHandler auth_uid=%s: %v", authUID, err)
		writeError(w, http.StatusInternalServerError, "profile query failed")
		return
	}

	writeJSON(w, http.StatusOK, u)
}

// CreateUserHandler handles POST /users/me.
// Creates a new profile row for the authenticated user.
// Returns 409 if the profile already exists (idempotent double-submit safety).
func (d *Deps) CreateUserHandler(w http.ResponseWriter, r *http.Request) {
	authUID := r.Header.Get("X-Cove-Uid")

	var req struct {
		Username string `json:"username"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || strings.TrimSpace(req.Username) == "" {
		writeError(w, http.StatusBadRequest, "username is required")
		return
	}

	const q = `
INSERT INTO profile.users (auth_uid, username)
VALUES ($1, $2)
RETURNING auth_uid, username, created_at`

	var u userProfile
	err := d.DB.QueryRow(r.Context(), q, authUID, strings.TrimSpace(req.Username)).
		Scan(&u.UID, &u.Username, &u.CreatedAt)
	if err != nil {
		if isDuplicate(err) {
			// Distinguish which unique constraint fired:
			//   users_auth_uid_key → same Firebase user posted twice (safe to retry)
			//   users_username_key → username already claimed by another user
			if duplicateConstraint(err) == "users_username_key" {
				writeError(w, http.StatusConflict, "username already taken")
				return
			}
			writeError(w, http.StatusConflict, "user already exists")
			return
		}
		log.Printf("ERROR CreateUserHandler auth_uid=%s: %v", authUID, err)
		writeError(w, http.StatusInternalServerError, "user creation failed")
		return
	}

	writeJSON(w, http.StatusCreated, u)
}

// ── Favorites ─────────────────────────────────────────────────────────────────

type favoriteItem struct {
	ItemID      string    `json:"item_id"`
	ItemName    string    `json:"item_name"`
	PriceCents  *int      `json:"price_cents,omitempty"`
	FavoritedAt time.Time `json:"favorited_at"`
}

type favoritesResponse struct {
	Favorites []favoriteItem `json:"favorites"`
	Total     int            `json:"total"`
}

// GetFavoritesHandler handles GET /users/me/favorites.
func (d *Deps) GetFavoritesHandler(w http.ResponseWriter, r *http.Request) {
	authUID := r.Header.Get("X-Cove-Uid")

	userID, ok := d.lookupUserID(r, w, authUID)
	if !ok {
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

	var total int
	err := d.DB.QueryRow(r.Context(),
		`SELECT COUNT(*) FROM profile.favorites WHERE user_id = $1`, userID).Scan(&total)
	if err != nil {
		log.Printf("ERROR GetFavoritesHandler count user_id=%s: %v", userID, err)
		writeError(w, http.StatusInternalServerError, "favorites query failed")
		return
	}

	const q = `
SELECT f.item_id, i.name, i.price_cents, f.created_at
FROM profile.favorites f
JOIN catalog.items i ON i.id = f.item_id
WHERE f.user_id = $1
ORDER BY f.created_at DESC
LIMIT $2 OFFSET $3`

	rows, err := d.DB.Query(r.Context(), q, userID, limit, offset)
	if err != nil {
		log.Printf("ERROR GetFavoritesHandler query user_id=%s: %v", userID, err)
		writeError(w, http.StatusInternalServerError, "favorites query failed")
		return
	}
	defer rows.Close()

	favorites := []favoriteItem{}
	for rows.Next() {
		var itemID pgtype.UUID
		var name string
		var priceCents *int32
		var favoritedAt time.Time
		if err := rows.Scan(&itemID, &name, &priceCents, &favoritedAt); err != nil {
			log.Printf("ERROR GetFavoritesHandler scan user_id=%s: %v", userID, err)
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
	authUID := r.Header.Get("X-Cove-Uid")
	itemID := chi.URLParam(r, "itemId")

	userID, ok := d.lookupUserID(r, w, authUID)
	if !ok {
		return
	}

	const q = `
INSERT INTO profile.favorites (user_id, item_id)
VALUES ($1, $2)
ON CONFLICT (user_id, item_id) DO NOTHING`

	ct, err := d.DB.Exec(r.Context(), q, userID, itemID)
	if err != nil {
		log.Printf("ERROR AddFavoriteHandler user_id=%s item=%s: %v", userID, itemID, err)
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
	authUID := r.Header.Get("X-Cove-Uid")
	itemID := chi.URLParam(r, "itemId")

	userID, ok := d.lookupUserID(r, w, authUID)
	if !ok {
		return
	}

	ct, err := d.DB.Exec(r.Context(),
		`DELETE FROM profile.favorites WHERE user_id = $1 AND item_id = $2`, userID, itemID)
	if err != nil {
		log.Printf("ERROR RemoveFavoriteHandler user_id=%s item=%s: %v", userID, itemID, err)
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
	EntityType string    `json:"entity_type"`
	EntityID   string    `json:"entity_id"`
	EntityName string    `json:"entity_name"`
	FollowedAt time.Time `json:"followed_at"`
}

type followsResponse struct {
	Follows []follow `json:"follows"`
}

// GetFollowsHandler handles GET /users/me/follows.
func (d *Deps) GetFollowsHandler(w http.ResponseWriter, r *http.Request) {
	authUID := r.Header.Get("X-Cove-Uid")

	userID, ok := d.lookupUserID(r, w, authUID)
	if !ok {
		return
	}

	const q = `
SELECT 'maker' AS entity_type, m.id, m.name, f.created_at
FROM profile.follows f
JOIN directory.makers m ON m.id = f.maker_id
WHERE f.user_id = $1 AND f.maker_id IS NOT NULL

UNION ALL

SELECT 'storefront' AS entity_type, s.id, s.name, f.created_at
FROM profile.follows f
JOIN directory.storefronts s ON s.id = f.storefront_id
WHERE f.user_id = $1 AND f.storefront_id IS NOT NULL

ORDER BY 4 DESC`

	rows, err := d.DB.Query(r.Context(), q, userID)
	if err != nil {
		log.Printf("ERROR GetFollowsHandler user_id=%s: %v", userID, err)
		writeError(w, http.StatusInternalServerError, "follows query failed")
		return
	}
	defer rows.Close()

	follows := []follow{}
	for rows.Next() {
		var entityType, entityName string
		var followedAt time.Time
		var entityID pgtype.UUID
		if err := rows.Scan(&entityType, &entityID, &entityName, &followedAt); err != nil {
			log.Printf("ERROR GetFollowsHandler scan user_id=%s: %v", userID, err)
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
	authUID := r.Header.Get("X-Cove-Uid")

	userID, ok := d.lookupUserID(r, w, authUID)
	if !ok {
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
		var existing int
		err := d.DB.QueryRow(r.Context(),
			`SELECT COUNT(*) FROM profile.follows WHERE user_id = $1 AND maker_id = $2`,
			userID, *req.MakerID).Scan(&existing)
		if err != nil {
			log.Printf("ERROR AddFollowHandler check maker user_id=%s maker=%s: %v", userID, *req.MakerID, err)
			writeError(w, http.StatusInternalServerError, "follow check failed")
			return
		}
		if existing > 0 {
			writeError(w, http.StatusConflict, "already following")
			return
		}

		_, err = d.DB.Exec(r.Context(),
			`INSERT INTO profile.follows (user_id, maker_id) VALUES ($1, $2)`,
			userID, *req.MakerID)
		if err != nil {
			log.Printf("ERROR AddFollowHandler insert maker user_id=%s maker=%s: %v", userID, *req.MakerID, err)
			writeError(w, http.StatusInternalServerError, "add follow failed")
			return
		}
	} else {
		var existing int
		err := d.DB.QueryRow(r.Context(),
			`SELECT COUNT(*) FROM profile.follows WHERE user_id = $1 AND storefront_id = $2`,
			userID, *req.StorefrontID).Scan(&existing)
		if err != nil {
			log.Printf("ERROR AddFollowHandler check storefront user_id=%s sf=%s: %v", userID, *req.StorefrontID, err)
			writeError(w, http.StatusInternalServerError, "follow check failed")
			return
		}
		if existing > 0 {
			writeError(w, http.StatusConflict, "already following")
			return
		}

		_, err = d.DB.Exec(r.Context(),
			`INSERT INTO profile.follows (user_id, storefront_id) VALUES ($1, $2)`,
			userID, *req.StorefrontID)
		if err != nil {
			log.Printf("ERROR AddFollowHandler insert storefront user_id=%s sf=%s: %v", userID, *req.StorefrontID, err)
			writeError(w, http.StatusInternalServerError, "add follow failed")
			return
		}
	}

	w.WriteHeader(http.StatusNoContent)
}

// RemoveFollowHandler handles DELETE /users/me/follows/{entityId}.
// Tries both maker_id and storefront_id columns.
func (d *Deps) RemoveFollowHandler(w http.ResponseWriter, r *http.Request) {
	authUID := r.Header.Get("X-Cove-Uid")
	entityID := chi.URLParam(r, "entityId")

	userID, ok := d.lookupUserID(r, w, authUID)
	if !ok {
		return
	}

	ct, err := d.DB.Exec(r.Context(),
		`DELETE FROM profile.follows WHERE user_id = $1 AND maker_id = $2`, userID, entityID)
	if err != nil {
		log.Printf("ERROR RemoveFollowHandler maker user_id=%s entity=%s: %v", userID, entityID, err)
		writeError(w, http.StatusInternalServerError, "remove follow failed")
		return
	}
	if ct.RowsAffected() > 0 {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	ct, err = d.DB.Exec(r.Context(),
		`DELETE FROM profile.follows WHERE user_id = $1 AND storefront_id = $2`, userID, entityID)
	if err != nil {
		log.Printf("ERROR RemoveFollowHandler storefront user_id=%s entity=%s: %v", userID, entityID, err)
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
	CategoryID   string    `json:"category_id"`
	CategoryPath string    `json:"category_path"`
	CategoryName string    `json:"category_name"`
	CreatedAt    time.Time `json:"created_at"`
}

type interestsResponse struct {
	Interests []interest `json:"interests"`
}

// GetInterestsHandler handles GET /users/me/interests.
func (d *Deps) GetInterestsHandler(w http.ResponseWriter, r *http.Request) {
	authUID := r.Header.Get("X-Cove-Uid")

	userID, ok := d.lookupUserID(r, w, authUID)
	if !ok {
		return
	}

	const q = `
SELECT i.category_id, c.path::text, c.name, i.created_at
FROM profile.interests i
JOIN catalog.categories c ON c.id = i.category_id
WHERE i.user_id = $1
ORDER BY c.name`

	rows, err := d.DB.Query(r.Context(), q, userID)
	if err != nil {
		log.Printf("ERROR GetInterestsHandler user_id=%s: %v", userID, err)
		writeError(w, http.StatusInternalServerError, "interests query failed")
		return
	}
	defer rows.Close()

	interests := []interest{}
	for rows.Next() {
		var categoryID pgtype.UUID
		var path, name string
		var createdAt time.Time
		if err := rows.Scan(&categoryID, &path, &name, &createdAt); err != nil {
			log.Printf("ERROR GetInterestsHandler scan user_id=%s: %v", userID, err)
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
	authUID := r.Header.Get("X-Cove-Uid")

	userID, ok := d.lookupUserID(r, w, authUID)
	if !ok {
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
		log.Printf("ERROR ReplaceInterestsHandler begin tx user_id=%s: %v", userID, err)
		writeError(w, http.StatusInternalServerError, "transaction failed")
		return
	}
	defer tx.Rollback(r.Context()) //nolint:errcheck

	if _, err := tx.Exec(r.Context(),
		`DELETE FROM profile.interests WHERE user_id = $1`, userID); err != nil {
		log.Printf("ERROR ReplaceInterestsHandler delete user_id=%s: %v", userID, err)
		writeError(w, http.StatusInternalServerError, "interests replace failed")
		return
	}

	for _, catID := range req.CategoryIDs {
		if _, err := tx.Exec(r.Context(),
			`INSERT INTO profile.interests (user_id, category_id) VALUES ($1, $2)
			 ON CONFLICT (user_id, category_id) DO NOTHING`,
			userID, catID); err != nil {
			log.Printf("ERROR ReplaceInterestsHandler insert user_id=%s cat=%s: %v", userID, catID, err)
			writeError(w, http.StatusInternalServerError, "interests replace failed")
			return
		}
	}

	if err := tx.Commit(r.Context()); err != nil {
		log.Printf("ERROR ReplaceInterestsHandler commit user_id=%s: %v", userID, err)
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
	authUID := r.Header.Get("X-Cove-Uid")

	userID, ok := d.lookupUserID(r, w, authUID)
	if !ok {
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
INSERT INTO profile.events (user_id, event_type, category_id, item_id, metadata)
VALUES ($1, $2, $3, $4, $5)`

	_, err := d.DB.Exec(r.Context(), q, userID, req.EventType, req.CategoryID, req.ItemID, metadata)
	if err != nil {
		log.Printf("ERROR IngestEventHandler user_id=%s type=%s: %v", userID, req.EventType, err)
		writeError(w, http.StatusInternalServerError, "event ingest failed")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// ── Helpers ───────────────────────────────────────────────────────────────────

// lookupUserID resolves an auth_uid to the internal profile.users UUID.
// On not-found it writes 404; on DB error it writes 500.
// Returns ("", false) in either error case — callers should return immediately.
func (d *Deps) lookupUserID(r *http.Request, w http.ResponseWriter, authUID string) (string, bool) {
	var id pgtype.UUID
	err := d.DB.QueryRow(r.Context(),
		`SELECT id FROM profile.users WHERE auth_uid = $1`, authUID).Scan(&id)
	if err != nil {
		if isNotFound(err) {
			writeError(w, http.StatusNotFound, "user profile not found")
		} else {
			log.Printf("ERROR lookupUserID auth_uid=%s: %v", authUID, err)
			writeError(w, http.StatusInternalServerError, "user lookup failed")
		}
		return "", false
	}
	return formatUUID(id), true
}
