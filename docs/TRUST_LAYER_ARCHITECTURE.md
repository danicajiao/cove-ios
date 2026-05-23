# Trust Layer Architecture

> **Status:** Direction document (May 2026). Captures a foundational revision to Cove's data model driven by the [Product Brief](https://github.com/danicajiao/cove) (v1.0). This supersedes the product-centric entity model in [Marketplace Architecture](MARKETPLACE_ARCHITECTURE.md); that document and [Postgres Primer](POSTGRES_PRIMER.md) need follow-up revision to match (tracked separately — see [Open Items](#open-items-for-phase-review)).

## Contents

- [Why this document exists](#why-this-document-exists)
- [The core reframe: the trust layer IS the product](#the-core-reframe-the-trust-layer-is-the-product)
- [Entity model: maker, seller, product](#entity-model-maker-seller-product)
- [The trust signal system](#the-trust-signal-system)
- [Composite trust scoring](#composite-trust-scoring)
- [Geospatial: the local availability gate](#geospatial-the-local-availability-gate)
- [The discovery query](#the-discovery-query)
- [What this changes vs the current docs](#what-this-changes-vs-the-current-docs)
- [What is deliberately deferred](#what-is-deliberately-deferred)
- [Open items for phase review](#open-items-for-phase-review)

---

## Why this document exists

The product brief reframes what Cove is. It is not a generic marketplace where users browse products and filter. It is a **local commerce discovery platform whose defensible advantage is a trust layer** — discovery rooted in verified business values, where visibility cannot be purchased.

The data model documented in [Marketplace Architecture](MARKETPLACE_ARCHITECTURE.md) was built for a product-centric, e-commerce-shaped marketplace (products, variants, SKUs, per-variant pricing). That shape solves the wrong problem. This document defines the entity model the actual product needs.

---

## The core reframe: the trust layer IS the product

From the brief (Section 7): *"Replicating individual elements (a map, a directory, a certification badge) is easy; replicating the system where all discovery is rooted in verified trust, and where visibility cannot be purchased, requires rebuilding the entire incentive structure from scratch."*

The consequences for architecture:

- **Discovery is a ranking problem, not a filtering problem.** Results are ranked by an additive trust score, scoped to proximity, matched to a query.
- **Trust signals are first-class structured data**, not display badges. They drive ranking.
- **Visibility is never for sale.** No paid placement, no promoted listings. The ranking function only consumes trust, proximity, and relevance.

---

## Entity model: maker, seller, product

The current model conflates "who makes a thing" and "where you buy it" into a single `vendor`. The brief requires separating them — *"Cove tells you who near you **makes or sells** it"* (Section 2).

| Entity | Role | Carries | Local-availability gate? |
|---|---|---|---|
| **brand** (maker) | Who produces the product | Provenance trust signals (B Corp, 1% for the Planet) | No — can be national |
| **storefront** (local seller) | Where you physically go to get it | Local-business trust signals (Living Wage, woman-owned, Community Verified) + **location** | **Yes — must be local** |
| **product** | What a user searches for | Its own trust signals (USDA Organic) + FK to a brand + FK to a storefront | Via its storefront |

### Why separating maker from seller matters

It correctly handles the cases the brief describes, and reframes the "national chains" concern:

- **A local boutique selling Patagonia.** Storefront = the boutique (local, its own signals). Brand = Patagonia (B Corp, national). The product carries Patagonia's brand trust *on top of* the boutique's local trust.
- **Patagonia's own RiNo store.** Patagonia surfaces *because* it has a local storefront AND genuine signals — not excluded for being national.
- **Walmart.** Has local stores too, but no meaningful trust signals, so the ranking buries it.

The rule is not "local only." It is **require a local point of sale, then rank by trust.** Size becomes irrelevant; local availability + verified trust is what wins. The geographic gate applies to the **storefront** (is there a real local place to go?); the trust ranking does the promotion.

### The same-organization case

A vertically integrated business — e.g. New Belgium Brewing with its own taproom — is modeled as a **brand** (New Belgium, B Corp) plus a **storefront** (the taproom, with location) it operates. Keeping them as separate rows is correct, not redundant, because:

- The brand can be sold at *other* storefronts (a local bottle shop), carrying its trust there.
- The storefront can sell *other* brands (guest taps), each carrying their own trust.

---

## The trust signal system

Signals attach at **three levels** — brand, storefront, and product. This is not three separate systems; it is **one signal taxonomy with one polymorphic attachment table.**

### Worked example: New Belgium Brewing

```
Brand: New Belgium Brewing
  └─ signal: B Corp Certified          ← company-level (the maker)

Storefront: New Belgium Taproom (RiNo)
  └─ signal: Living Wage Certified     ← local-business-level (has the location)

Product: "The Purist Clean Lager"  (made by New Belgium)
  └─ signal: USDA Organic              ← product-level (this beer only)

Product: "Fat Tire"  (made by New Belgium)
  └─ (no organic signal)               ← same brand, no product-level cert
```

Discovering "Purist Clean Lager" yields **B Corp (from the brand) + Living Wage (from the storefront) + USDA Organic (from the product)**. "Fat Tire" at the same taproom carries B Corp + Living Wage but not organic. Product-level signals differentiate products from the same maker.

### Signal taxonomy (from brief Section 7)

| Signal | Verification method | Typical level |
|---|---|---|
| B Corp Certified | Cross-reference B Lab directory | brand |
| USDA Organic | Cross-reference USDA directory | product (sometimes brand) |
| Fair Trade Certified | Cross-reference issuing body | product / brand |
| 1% for the Planet | Cross-reference member directory | brand |
| Colorado Proud | CO Dept. of Agriculture (location-tied) | brand / product |
| Living Wage Certified | Cross-reference Living Wage directory | storefront / brand |
| Community Verified | Community vouching (softer signal) | storefront / brand |
| DUNS-verified ("Verified Business" tier) | DUNS number lookup | storefront / brand |

### Schema sketch

The taxonomy is defined once; attachments use an **exclusive arc** — three nullable foreign keys with a `CHECK` enforcing exactly one is set. This preserves real FKs (so deleting a product/brand/storefront cascades its signals away) while keeping a single attachment table.

```sql
-- Reference taxonomy — one row per signal type, defined once
CREATE TABLE signals (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    code                text NOT NULL UNIQUE,   -- 'b_corp', 'usda_organic', ...
    name                text NOT NULL,
    description         text,
    verification_method text NOT NULL,          -- 'directory_crossref' | 'duns' | 'community_vouch'
    weight              numeric NOT NULL DEFAULT 1   -- contribution to the trust score
);

-- Polymorphic attachment — links a signal to exactly one entity
CREATE TABLE entity_signals (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    signal_id     uuid NOT NULL REFERENCES signals(id),
    brand_id      uuid REFERENCES brands(id)       ON DELETE CASCADE,
    storefront_id uuid REFERENCES storefronts(id)  ON DELETE CASCADE,
    product_id    uuid REFERENCES products(id)     ON DELETE CASCADE,
    status        text NOT NULL DEFAULT 'pending', -- 'verified' | 'pending' | 'community_vouched'
    verified_at   timestamptz,
    verified_via  text,                            -- directory URL, DUNS #, voucher reference
    created_at    timestamptz NOT NULL DEFAULT now(),
    -- exclusive arc: exactly one entity FK is set
    CHECK (num_nonnulls(brand_id, storefront_id, product_id) = 1)
);

CREATE INDEX ON entity_signals (brand_id);
CREATE INDEX ON entity_signals (storefront_id);
CREATE INDEX ON entity_signals (product_id);
```

Adding a new signal type later (e.g. "Certified Plastic Negative") is a single `INSERT` into `signals` — no schema change.

---

## Composite trust scoring

A discovery result aggregates trust across the three levels:

```
result_trust_score(product, brand, storefront) =
      brand.trust_score          -- materialized from brand signals (B Corp, etc.)
    + storefront.trust_score     -- materialized from storefront signals (Living Wage, etc.)
    + Σ product's own signals    -- USDA Organic, etc. — usually 0–2, added at query time
```

**Materialize** `brand.trust_score` and `storefront.trust_score` (recompute when their signals change — a rare event), and add the product's own signals live. Brand and storefront scores get a B-tree index so the discovery `ORDER BY` is cheap.

The brief's "rewards breadth and diversity of trust signals rather than any single credential" (Section 7) is a refinement of *how* the sum works — diminishing returns on stacking similar signals, a bonus for spanning signal categories. **Start with flat additive weights** and tune the function later; this does not block the schema.

---

## Geospatial: the local availability gate

Location is doubly mandatory — it is both the proximity dimension of discovery *and* the integrity gate (*"all listings require a verifiable local address within the Denver metro area; this prevents national chains from self-listing as local"* — Section 7).

The standard for radius search on Postgres is **PostGIS** — a `geography` column with a **GiST index**, queried with `ST_DWithin`. (Not application-level geohashing; PostGIS computes true great-circle distance and avoids geohash boundary problems.)

```sql
ALTER TABLE storefronts ADD COLUMN location geography(Point, 4326);
CREATE INDEX ON storefronts USING GIST (location);

-- "storefronts within 20 miles of Denver" — 20 mi = 32186.9 meters
SELECT * FROM storefronts
WHERE ST_DWithin(location, ST_MakePoint(-104.99, 39.74)::geography, 32186.9);
```

> **Infra note:** PostGIS is not bundled in vanilla Postgres images the way `ltree` is. CNPG must be configured to load the PostGIS extension before Phase 3 schema work — an open homelab item.

---

## The discovery query

The discovery query is the product. A search like "handmade ceramics near me" composes **three index types in one statement** — proximity (GiST), relevance (GIN full-text), and trust (materialized scores) — blended into a single ranking:

```sql
SELECT
    p.id, p.name,
    b.name  AS brand_name,
    s.name  AS storefront_name,
    ST_Distance(s.location, $loc)            AS distance_m,
    ts_rank(p.search_vec, q)                 AS relevance,
    b.trust_score + s.trust_score            AS base_trust   -- product signals added below
FROM products p
JOIN brands      b ON b.id = p.brand_id
JOIN storefronts s ON s.id = p.storefront_id,
     websearch_to_tsquery('english', $query) q
WHERE ST_DWithin(s.location, $loc, $radius)  -- GiST: proximity gate
  AND p.search_vec @@ q                       -- GIN: relevance match
ORDER BY (
      $w_trust     * (b.trust_score + s.trust_score)
    + $w_relevance * ts_rank(p.search_vec, q)
    + $w_proximity * (1.0 / (1 + ST_Distance(s.location, $loc)))
) DESC
LIMIT 25;
```

That `ORDER BY` blend is Cove's secret sauce. Yelp ranks by ad spend; Google by review volume. Cove ranks by **trust + proximity + relevance** — the thing competitors cannot cheaply copy, because it requires rebuilding the incentive structure (the brief's defensibility argument).

---

## What this changes vs the current docs

| Current ([Marketplace Architecture](MARKETPLACE_ARCHITECTURE.md)) | New direction |
|---|---|
| `vendor` schema — thin, deferred, owned by no service in Phase 3 | Split into **brand** (maker) + **storefront** (local seller); both are first-class and carry trust |
| `product.products` is the load-bearing core | Products are the *search surface*; the **business graph + trust layer** is the core |
| `product_variants` (SKU, options, per-variant price) | Likely over-built — no transactions in v1; products may be lighter discovery records |
| No location anywhere | **PostGIS `geography` + GiST** on storefronts — the proximity dimension and the integrity gate |
| `attributes jsonb` for ad-hoc traits | Trust signals are a structured **taxonomy + polymorphic attachment**, not loose jsonb |
| Discovery = filter by category/attribute | Discovery = **rank by composite trust + proximity + relevance** |

`ltree` categories, `users`, `favorites`, and `follows` carry over unchanged. (`follows` likely points at brands and/or storefronts rather than a single `vendor`.)

---

## What is deliberately deferred

- **Sophisticated scoring** — start flat-additive; add diversity/diminishing-returns tuning later.
- **Same product across multiple storefronts** — one product row per storefront is acceptable for v1. Promoting `product` to brand-owned with a `sold_at` join is a clean later migration if de-duplication becomes valuable.
- **pgvector / semantic search** — Postgres full-text (`tsvector`/GIN) is sufficient for v1 keyword discovery. Vector embeddings become relevant when the AI-assisted discovery feature is scoped; the schema should leave room but not build it now.
- **Availability signals** (market schedules, gallery hours, pop-up dates) — brief v3.
- **`cove-vendor` / business onboarding self-serve flow** — high-touch manual onboarding seeds the first 50 businesses (brief Section 4); the service comes later.

---

## Open items for phase review

These need reconciling before the Phase 3 epic is planned in detail:

1. **Revise [Marketplace Architecture](MARKETPLACE_ARCHITECTURE.md)** to the brand/storefront/product/trust-signal model (entities, schema, request flow, iOS repository layer).
2. **Add a geospatial section to [Postgres Primer](POSTGRES_PRIMER.md)** — PostGIS, `geography`, GiST for spatial, `ST_DWithin`, the meters-vs-miles gotcha.
3. **Service ownership** — which service owns brands, storefronts, products, and the signal taxonomy? (Likely `cove-product` for products/categories; brands + storefronts + signals may warrant their own service or a renamed `cove-vendor`.)
4. **Schema-per-service mapping** — reconcile the new entities with the single-cluster, schema-per-service topology.
5. **PostGIS in CNPG** — confirm the extension can be provisioned on the homelab Postgres before Phase 3.
6. **Reassess `product_variants`/`product_details`** — keep, simplify, or drop given no transactions in v1.

---

## References

- Product Brief v1.0 — the source of this direction (the trust layer, the wedge, the signal taxonomy)
- [Marketplace Architecture](MARKETPLACE_ARCHITECTURE.md) — current (to be revised) data layer
- [Postgres Primer](POSTGRES_PRIMER.md) — indexing concepts (needs a geospatial section)
- [Backend Infrastructure](BACKEND_INFRASTRUCTURE.md) — cluster topology and migration phases
- [Category & Product Architecture](CATEGORY_AND_PRODUCT_ARCHITECTURE.md) — category hierarchy and filtering
