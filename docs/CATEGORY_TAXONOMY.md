# Category Taxonomy

> **Keep this doc in sync:** The authoritative runtime state is the live database. The audit trail is the migration files. This document is the human-readable snapshot — update it in the same PR as any migration that adds, removes, or renames a category node.

## Contents

- [Overview](#overview)
- [Design principles](#design-principles)
- [v1 taxonomy](#v1-taxonomy)
- [Adding a category](#adding-a-category)
- [Removing a category](#removing-a-category)
- [Database integrity rules](#database-integrity-rules)

---

## Overview

Cove's category taxonomy is a **3-level tree** stored in Postgres using the `ltree` extension. Each node has a dot-separated path (`food.coffee.whole_bean`) and a display name (`Whole Bean`). The path is the stable identity; the name is what the iOS app shows.

Items may only be assigned to **leaf nodes** — the deepest node in a given branch. Non-leaf categories are browse/navigation nodes only; they cannot be set as an item's `category_id`.

The v1 taxonomy has **9 top-level categories** and ~140 nodes total, seeded via migration `000004`. Leaf enforcement is added by migrations `000005` and `000006`.

---

## Design principles

### Tree nodes vs attributes

> **Categories define *what* an item is. Attributes define *how it differs from others in the same category*.**

A new category branch is warranted when:
- The distinction is **fixed and mutually exclusive** (an item is either beer or wine, not both)
- The set is **small and stable** (adding 10 new nodes does not spiral the tree)
- The difference changes **what the item fundamentally is**, not a property of it

A new `attributes` key is warranted when:
- The values **overlap** (an item can be both organic and locally sourced)
- The set is **open-ended or continuous** (dietary tags, ABV, season)
- The distinction is a **filter facet**, not a categorical identity

Examples of deliberate attribute choices:
- **Gender** (men's/women's/unisex) — an item can be unisex; the tree would duplicate every clothing node three times. Lives on `attributes`.
- **Dietary tags** (vegan, gluten-free, organic) — a product can carry many of these simultaneously. Lives on `attributes`.
- **Beer style details** (ABV, IBU) — continuous numeric values; range filtering requires typed attributes, not tree nodes.
- **Wine characteristics** (tannins, skin contact) — tasting notes and production method are facets, not identity.

### 3-level cap

The v1 taxonomy is capped at **3 levels** (`root.mid.leaf` — e.g. `food.coffee.whole_bean`). This is deep enough to power homepage category cards and category-scoped discovery without creating a maintenance burden. Some branches are deliberately shallower (2 levels, e.g. `art.paintings`) — the cap is a maximum, not a requirement.

### Why alcohol is separate from food

Alcohol has distinct regulatory, cultural, and discovery contexts. Grouping `food.beer` alongside `food.baked_goods` would make browse-mode category cards confusing and would complicate any future age-gating. Keeping it as a top-level `alcohol` preserves that separation cleanly.

---

## v1 taxonomy

```
food
├── coffee
│   ├── whole_bean
│   ├── ground
│   └── cold_brew
├── tea
│   ├── loose_leaf
│   ├── blends
│   └── herbal
├── beverages
│   ├── kombucha
│   ├── juice
│   └── soda
├── baked_goods
│   ├── breads
│   ├── pastries
│   ├── cakes
│   ├── pies
│   └── cookies
├── confections
│   ├── chocolate
│   ├── caramels
│   ├── fudge
│   ├── taffy
│   └── candy
├── preserves
│   ├── jams
│   ├── jellies
│   ├── fruit_butters
│   ├── chutneys
│   └── pickles
├── snacks
│   ├── granola
│   ├── jerky
│   ├── popcorn
│   ├── nuts
│   ├── chips
│   └── trail_mix
├── condiments
│   ├── hot_sauce
│   ├── salsa
│   ├── mustard
│   ├── vinegar
│   ├── spices
│   └── oils
├── fresh
│   ├── pasta
│   ├── sauces
│   └── dips
├── produce
│   ├── vegetables
│   ├── fruits
│   ├── mushrooms
│   ├── herbs
│   └── eggs
├── proteins
│   ├── beef
│   ├── poultry
│   ├── pork
│   ├── fish
│   └── game
├── dairy
│   ├── cheese
│   ├── milk
│   ├── butter
│   ├── ice_cream
│   └── yogurt
└── pantry
    ├── syrups
    ├── sweeteners
    ├── honey
    ├── baking
    └── grains

alcohol
├── beer
│   ├── ipa
│   ├── stout
│   ├── lager
│   ├── wheat
│   ├── sour
│   ├── amber
│   └── specialty
├── cider
│   ├── apple
│   └── specialty
├── wine
│   ├── red
│   ├── white
│   ├── rose
│   ├── sparkling
│   └── specialty
└── spirits
    ├── whiskey
    ├── gin
    ├── vodka
    ├── rum
    ├── tequila
    └── specialty

apparel
├── mens
│   ├── tops
│   ├── bottoms
│   └── outerwear
├── womens
│   ├── tops
│   ├── bottoms
│   ├── dresses
│   └── outerwear
├── unisex
│   ├── tops
│   ├── bottoms
│   └── outerwear
├── accessories
│   ├── hats
│   ├── belts
│   ├── bags
│   ├── scarves
│   ├── gloves
│   └── shoes
└── jewelry
    ├── necklaces
    ├── earrings
    ├── rings
    └── bracelets

home
├── decor
│   ├── candles
│   └── ceramics
├── kitchen
│   ├── ceramics
│   ├── cutting_boards
│   ├── utensils
│   └── linens
├── textiles
│   ├── blankets
│   ├── pillows
│   └── throws
└── furniture
    ├── tables
    ├── seating
    └── shelving

plants
├── indoor
│   ├── succulents
│   ├── tropicals
│   └── herbs
├── outdoor
│   ├── perennials
│   ├── annuals
│   └── shrubs
├── seeds
│   ├── vegetable
│   ├── flower
│   ├── fruit
│   └── herb
├── dried
│   ├── bouquets
│   ├── wreaths
│   └── arrangements
└── plantcare
    ├── soil
    ├── fertilizer
    ├── pots
    └── tools

beauty
├── cosmetics
│   ├── face
│   ├── eyes
│   ├── lips
│   └── nails
├── skincare
│   ├── cleansers
│   ├── moisturizers
│   ├── serums
│   ├── oils
│   └── spf
├── bodycare
│   ├── soap
│   ├── bath_bombs
│   ├── scrubs
│   ├── bath_salts
│   └── lotion
├── haircare
│   ├── shampoo
│   ├── conditioner
│   ├── masks
│   ├── oils
│   └── styling
├── fragrance
│   ├── perfume
│   ├── cologne
│   ├── body_spray
│   └── solid
└── supplements
    ├── vitamins
    └── herbal

art
├── paintings           ← leaf at level 2
├── prints              ← leaf at level 2
├── sculptures          ← leaf at level 2
├── photography         ← leaf at level 2
├── drawings            ← leaf at level 2
└── materials
    ├── paint
    ├── brushes
    ├── canvas
    ├── paper
    └── ink

pets
├── dogs
│   ├── food
│   ├── accessories
│   ├── grooming
│   └── toys
├── cats
│   ├── food
│   ├── accessories
│   ├── grooming
│   └── toys
├── birds
│   ├── food
│   ├── accessories
│   └── toys
└── exotic
    ├── food
    └── accessories

music
├── instruments
│   ├── guitars
│   ├── violins
│   ├── drums
│   ├── keyboards
│   ├── bass
│   └── trumpet
├── recorded
│   ├── vinyl
│   ├── cd
│   └── cassette
└── accessories
    ├── cases
    ├── string_sets
    └── picks
```

---

## Adding a category

**Choose the right level first.** Review [Design principles](#design-principles) before adding a node. If the distinction is a filter facet, it belongs in `attributes`, not the tree.

### 1. Write a new migration

Create the next numbered migration file:

```bash
# example: adding food.fresh.kimchi
touch services/cove-item/migrations/000007_add_kimchi_category.up.sql
touch services/cove-item/migrations/000007_add_kimchi_category.down.sql
```

**up:**
```sql
INSERT INTO catalog.categories (id, name, path)
VALUES (gen_random_uuid(), 'Kimchi', 'food.fresh.kimchi')
ON CONFLICT (path) DO UPDATE SET name = EXCLUDED.name;
```

**down:**
```sql
-- Only safe if no items reference this category.
-- The FK constraint will block this if items exist.
DELETE FROM catalog.categories WHERE path = 'food.fresh.kimchi';
```

> The `AFTER INSERT` trigger automatically marks `food.fresh` as `is_leaf = false` — no manual update needed.

### 2. Update this document

Add the new node to the tree above. Keep it in the same PR as the migration.

### 3. Run the migration

```bash
# From the repo root
migrate -path services/cove-item/migrations \
        -database "postgres://..." \
        -x-migrations-table schema_migrations_cove_item \
        up
```

See [DATABASE_MIGRATIONS.md](DATABASE_MIGRATIONS.md) for the full connection string and staging runbook.

---

## Removing a category

Removing a category from the live database requires care — items may already be assigned to it.

### Steps

1. **Check for dependent items** before writing the migration:
   ```sql
   SELECT COUNT(*) FROM catalog.items
   WHERE category_id = (SELECT id FROM catalog.categories WHERE path = 'food.fresh.kimchi');
   ```
   If any items exist, reassign or remove them first in a separate migration.

2. **Remove children first** if the node has any. The `BEFORE DELETE` trigger blocks deletion of a non-leaf category — you must delete all descendants bottom-up, or delete them in the same migration in the correct order.

3. **Write the migration:**

   **up:**
   ```sql
   -- Remove leaf first, then parent (if parent becomes a leaf again, the
   -- AFTER DELETE trigger updates is_leaf automatically).
   DELETE FROM catalog.categories WHERE path = 'food.fresh.kimchi';
   ```

   **down:**
   ```sql
   INSERT INTO catalog.categories (id, name, path)
   VALUES (gen_random_uuid(), 'Kimchi', 'food.fresh.kimchi')
   ON CONFLICT (path) DO UPDATE SET name = EXCLUDED.name;
   ```

4. **Update this document** to remove the node from the tree above.

---

## Database integrity rules

Four triggers on `catalog.categories` and `catalog.items` enforce taxonomy integrity automatically. You do not need to maintain `is_leaf` manually.

| Trigger | Table | Fires | What it does |
|---|---|---|---|
| `categories_mark_parent_non_leaf` | `catalog.categories` | `AFTER INSERT` | Marks the inserted node's direct parent as `is_leaf = false` |
| `categories_recheck_parent_leaf` | `catalog.categories` | `AFTER DELETE` | Re-evaluates the deleted node's parent; flips it back to `is_leaf = true` if no siblings remain |
| `categories_prevent_non_leaf_delete` | `catalog.categories` | `BEFORE DELETE` | Raises an exception if the category still has children |
| `items_enforce_leaf_category` | `catalog.items` | `BEFORE INSERT OR UPDATE` | Raises an exception if `category_id` points to a non-leaf category |

The `RESTRICT` foreign key on `catalog.items.category_id` provides a fifth layer: Postgres itself will block deletion of any category that has items referencing it, before any trigger fires.

Defined in:
- `services/cove-item/migrations/000005_category_leaf_constraint.up.sql` — `is_leaf` column, backfill, insert trigger, item enforcement trigger
- `services/cove-item/migrations/000006_category_delete_integrity.up.sql` — delete guard trigger, parent recheck trigger

---

## References

- [Marketplace Architecture](MARKETPLACE_ARCHITECTURE.md) — schema overview, ltree mechanics, attributes vs categories
- [Postgres Primer](POSTGRES_PRIMER.md) — ltree operator reference
- [Database Migrations](DATABASE_MIGRATIONS.md) — how to run migrations against staging
