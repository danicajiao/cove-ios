# Category and Product Architecture

## Overview

This document outlines the recommended architecture for Cove's category hierarchy and product filtering system, specifically addressing multi-level categories and gender-based navigation.

---

## Category Structure

### Hybrid Approach: Parent Reference + Materialized Path

This combines the flexibility of parent references with the query power of materialized paths.

```javascript
categories/{categoryId}
  - id: "shirts-tees"                    // Unique identifier
  - name: "Shirts & Tees"                // Display name
  - slug: "shirts-tees"                  // URL-friendly
  - parentId: "clothing-shoes"           // Reference to parent category
  - ancestors: ["fashion-beauty", "clothing-shoes"]  // All ancestor IDs
  - path: "/fashion-beauty/clothing-shoes/shirts-tees"  // Full path for URLs
  - level: 2                             // Depth in hierarchy (0 = top level)
  - order: 1                             // Sort order within parent
  - imageURL: "..."                      // Category image
  - isActive: true                       // Visibility toggle
```

### Example Hierarchy

```
Fashion & Beauty (level: 0, parentId: null)
├── Clothing, Shoes, Jewelry & Watches (level: 1, parentId: "fashion-beauty")
│   ├── Shirts & Tees (level: 2, parentId: "clothing-shoes")
│   ├── Denim (level: 2, parentId: "clothing-shoes")
│   └── Shoes (level: 2, parentId: "clothing-shoes")
└── Beauty & Personal Care (level: 1, parentId: "fashion-beauty")
```

### Category Queries

**Get top-level categories:**
```swift
db.collection("categories")
  .whereField("parentId", isEqualTo: nil)
  .order(by: "order")
```

**Get children of a category:**
```swift
db.collection("categories")
  .whereField("parentId", isEqualTo: "fashion-beauty")
  .order(by: "order")
```

**Get all descendants of a category:**
```swift
db.collection("categories")
  .whereField("ancestors", arrayContains: "fashion-beauty")
```

**Get breadcrumb path:**
```swift
// From ancestors array: ["fashion-beauty", "clothing-shoes"]
// Fetch these category documents to build breadcrumb
```

---

## Gender Handling

### ✅ Recommended: Gender as Product Attribute

Gender should be a **filter/facet**, not part of the category tree.

#### Why Not Category-Based?

❌ **Bad Approach:**
```
Men > Clothing > Shirts
Women > Clothing > Shirts
Kids > Clothing > Shirts
```

**Problems:**
- 3x category management overhead
- Can't easily show "All Shirts"
- Unisex products must be duplicated
- Rigid, hard to expand

#### ✅ Good Approach: Product Attributes

```javascript
products/{productId}
  - categoryId: "shirts-tees"
  - genders: ["men"]           // Array: ["men"], ["women"], ["unisex"], or ["men", "women"]
  - sizes: ["S", "M", "L"]
  - colors: ["black", "white"]
  - brand: "Nike"
```

**Benefits:**
- Single category tree
- Flexible filtering
- Unisex product support
- Easy to combine filters

---

## Product Structure

### Complete Product Document

```javascript
products/{productId}
  // Basic Info
  - name: "Classic Cotton T-Shirt"
  - defaultPrice: 29.99
  - defaultImageURL: "gs://..."
  
  // Category
  - categoryId: "shirts-tees"                              // Primary category (leaf node)
  - categoryAncestors: ["fashion-beauty", "clothing", "shirts-tees"]  // For hierarchical queries
  
  // Attributes (Filters/Facets)
  - genders: ["men", "women"]    // Array allows unisex
  - sizes: ["XS", "S", "M", "L", "XL"]
  - colors: ["black", "white", "gray"]
  - tags: ["casual", "summer", "cotton"]
  - brand: "Nike"
  
  // Additional
  - info: { ... }                // Product-type specific info
  - productDetailsId: "..."      // Reference to product_details
  - createdAt: timestamp
  - isFavorite: null             // Set client-side
```

### Product Queries

**Men's shirts:**
```swift
db.collection("products")
  .whereField("categoryId", isEqualTo: "shirts-tees")
  .whereField("genders", arrayContains: "men")
```

**Women's clothing (all categories under "clothing"):**
```swift
db.collection("products")
  .whereField("categoryAncestors", arrayContains: "clothing")
  .whereField("genders", arrayContains: "women")
```

**All shirts (no gender filter):**
```swift
db.collection("products")
  .whereField("categoryId", isEqualTo: "shirts-tees")
```

**Combined filters (Women's Nike shoes under $50):**
```swift
db.collection("products")
  .whereField("categoryId", isEqualTo: "shoes")
  .whereField("genders", arrayContains: "women")
  .whereField("brand", isEqualTo: "Nike")
  .whereField("defaultPrice", isLessThan: 50)
```

---

## UI Navigation Flow

### Gender Entry Points

Gender-based navigation is implemented at the **UI level**, not as separate categories:

```javascript
// UI Configuration (could be in Firebase or hardcoded)
navigationLinks: [
  {
    label: "Shop Women's",
    filter: { gender: "women" },
    featuredCategories: ["dresses", "shoes", "jewelry"]
  },
  {
    label: "Shop Men's", 
    filter: { gender: "men" },
    featuredCategories: ["shirts", "pants", "shoes"]
  },
  {
    label: "Shop Kids",
    filter: { gender: "kids" },
    featuredCategories: ["toys", "clothing"]
  }
]
```

### Example User Flow

1. **Home Screen** → User taps "Shop Men's" button
2. **Gender Filter Applied:** `genders = ["men"]`
3. **Show Categories** that have men's products (can filter categories by checking if they have products)
4. **User Clicks** "Shirts & Tees" category
5. **Query Products:**
   ```swift
   categoryId = "shirts-tees" AND 
   genders arrayContains "men"
   ```
6. **Display** filtered products with additional filter options (brand, price, size, color)

### Breadcrumb Example

```
Home > Men's > Clothing > Shirts & Tees
```

**Implementation:**
- "Home" = root
- "Men's" = gender filter (not a category)
- "Clothing" = ancestor category
- "Shirts & Tees" = current category

---

## Benefits of This Architecture

### ✅ Flexibility
- Single category tree to maintain
- Easy to add/remove/reorder categories
- Supports unlimited hierarchy depth

### ✅ Performance
- Efficient queries with `ancestors` array
- Can query entire branches
- Minimal document reads

### ✅ Scalability
- Gender as attribute scales to any facet (age, season, style)
- Can combine multiple filters
- Supports unisex/multi-gender products

### ✅ User Experience
- Amazon-style browsing
- Clear navigation paths
- Flexible filtering

---

## Implementation Checklist

### Phase 1: Category Setup
- [ ] Create `categories` collection with recommended fields
- [ ] Populate hierarchy with `parentId` and `ancestors`
- [ ] Add `level` and `order` for display

### Phase 2: Product Updates
- [ ] Add `genders` array field to products
- [ ] Add `categoryAncestors` array field
- [ ] Update existing products with gender data

### Phase 3: UI Implementation
- [ ] Implement gender navigation buttons
- [ ] Create category browser with hierarchy
- [ ] Build filtering UI
- [ ] Add breadcrumb navigation

### Phase 4: Queries
- [ ] Implement category hierarchy queries
- [ ] Add gender filtering to product queries
- [ ] Support combined filters (gender + category + price + brand)

---

## References

This architecture is based on patterns used by:
- Amazon's category and filtering system
- Nike's product navigation
- E-commerce best practices for Firestore

**Key Principle:** Categories define **what** the product is. Attributes (gender, size, color, brand) define **who it's for** and **variations**.
