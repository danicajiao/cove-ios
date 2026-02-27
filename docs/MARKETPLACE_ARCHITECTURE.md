# Marketplace App: Hybrid SQL, NoSQL & GraphQL Architecture

## Overview

This architecture is for a marketplace app with commerce (transactional) and social (user-generated content) features, supporting both iOS and Web clients. It leverages:
- **SQL backend** for structured, transactional data (products, orders, users).
- **NoSQL backend** for flexible, rapidly evolving social data (reviews, comments, feeds).
- **GraphQL API layer** for unifying data queries and flexible client consumption.

---

## When to Use SQL vs. NoSQL

| Feature                       | Backend   | Notes                                                           |
|-------------------------------|-----------|-----------------------------------------------------------------|
| User accounts/profiles        | SQL       | Structured, relational, secure, supports ACID transactions.     |
| Product listings              | SQL       | Structured, support for relationships (vendor, category, etc).  |
| Orders/payments               | SQL       | Complex transactions, critical for commerce reliability.        |
| Vendor management             | SQL       | Relational data, strong consistency.                            |
| Social posts/feeds            | NoSQL     | Flexible schema, high-volume, schema-less, horizontal scaling.  |
| Reviews/comments              | NoSQL     | Rapid writes, unstructured or semi-structured.                  |
| Likes/follows/notifications   | NoSQL     | High frequency, event-driven, scalable.                         |
| Chat/messaging                | NoSQL     | Real-time, fast ingestion, loose schema.                        |
| Analytics/logs                | NoSQL     | High volume, ephemeral or aggregate data.                       |

---

## Example: Merging Data for a Product Page

### API Design

Query a single product's data and its associated reviews/comments:

- **SQL**: Fetch product details
- **NoSQL**: Fetch reviews/comments

### Example REST API Pseudocode

```python
def get_product_page(product_id):
    product = sql_query("SELECT * FROM products WHERE id = ?", [product_id])           # SQL
    reviews = nosql_query({"productId": product_id}, collection="reviews")             # NoSQL
    return {
        "product": product,
        "reviews": reviews
    }
```

---

## GraphQL Integration

GraphQL acts as a unified data facade, letting clients request exactly what they need from both SQL and NoSQL (or any service):

### Why Use GraphQL?

- One endpoint for aggregated resources
- Precise and flexible data requests (avoid over- or under-fetching)
- Cleanly merge relational (SQL) and document-based (NoSQL) data in queries

### Example GraphQL Query

```graphql
query GetProductAndReviews($id: ID!) {
  product(id: $id) {
    id
    name
    price
    vendor
    reviews(limit: 5) {
      user
      rating
      comment
    }
  }
}
```

#### Resolvers

- `product`: Resolver queries SQL backend.
- `reviews`: Resolver queries NoSQL backend using `product.id`.

#### Example Response (GraphQL API)

```json
{
  "product": {
    "id": "p123",
    "name": "Local Honey",
    "price": 12.00,
    "vendor": "Sunrise Apiaries",
    "reviews": [
      { "user": "jane", "rating": 5, "comment": "Great quality!" },
      { "user": "sam", "rating": 4, "comment": "Loved the taste." }
    ]
  }
}
```

---

## Client Implementation Examples

### iOS Client (Swift)

```swift
import Foundation

struct Product: Codable {
    let id: String
    let name: String
    let price: Double
    let vendor: String
}

struct Review: Codable {
    let user: String
    let rating: Int
    let comment: String
}

struct ProductResponse: Codable {
    let product: Product
    let reviews: [Review]
}

class ProductService {
    func fetchProductPage(productId: String, completion: @escaping (ProductResponse?) -> Void) {
        guard let url = URL(string: "https://api.yourmarketplace.com/graphql") else { return }
        
        let query = """
        query GetProductAndReviews($id: ID!) {
          product(id: $id) {
            id
            name
            price
            vendor
            reviews(limit: 5) {
              user
              rating
              comment
            }
          }
        }
        """
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["query": query, "variables": ["id": productId]]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            let decoded = try? JSONDecoder().decode(ProductResponse.self, from: data)
            completion(decoded)
        }.resume()
    }
}
```

### Web Client (JavaScript/React)

```javascript
import React, { useEffect, useState } from 'react';

const ProductPage = ({ productId }) => {
  const [product, setProduct] = useState(null);
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const query = `
      query GetProductAndReviews($id: ID!) {
        product(id: $id) {
          id
          name
          price
          vendor
          reviews(limit: 5) {
            user
            rating
            comment
          }
        }
      }
    `;

    fetch('https://api.yourmarketplace.com/graphql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ query, variables: { id: productId } })
    })
      .then(res => res.json())
      .then(data => {
        setProduct(data.product);
        setReviews(data.reviews);
        setLoading(false);
      });
  }, [productId]);

  if (loading) return <div>Loading...</div>;

  return (
    <div>
      <h1>{product.name}</h1>
      <p>Price: ${product.price}</p>
      <p>Vendor: {product.vendor}</p>
      <div>
        {reviews.map((review, idx) => (
          <div key={idx}>
            <strong>{review.user}</strong> ({review.rating}/5): {review.comment}
          </div>
        ))}
      </div>
    </div>
  );
};

export default ProductPage;
```

---

## Database Schema Examples

### SQL Database (PostgreSQL)

```sql
-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vendors table
CREATE TABLE vendors (
    id SERIAL PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    business_name VARCHAR(255),
    description TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Products table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    vendor_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2),
    inventory INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id)
);

-- Orders table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    total DECIMAL(10, 2),
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Order items table
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT,
    price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);
```

### NoSQL Database (Firestore Document Examples)

#### Reviews Collection

```json
{
  "reviews": [
    {
      "id": "review_001",
      "productId": "p123",
      "user": "jane",
      "userId": "user_456",
      "rating": 5,
      "comment": "Great quality honey, highly recommend!",
      "createdAt": "2025-11-22T10:30:00Z",
      "likes": 12
    }
  ]
}
```

#### Social Posts Collection

```json
{
  "posts": [
    {
      "id": "post_001",
      "userId": "user_456",
      "content": "Just tried the best local honey from Sunrise Apiaries!",
      "image": "url_to_image",
      "createdAt": "2025-11-22T09:15:00Z",
      "likes": 45,
      "comments": 8
    }
  ]
}
```

#### Notifications Collection

```json
{
  "notifications": [
    {
      "id": "notif_001",
      "userId": "user_456",
      "type": "new_review",
      "message": "jane left a review on your product",
      "relatedProductId": "p123",
      "read": false,
      "createdAt": "2025-11-22T11:00:00Z"
    }
  ]
}
```

---

## Deployment on Google Cloud Platform (GCP)

### Architecture Overview

1. **API Layer**: Host GraphQL or REST API on Cloud Run or App Engine
2. **SQL Database**: Cloud SQL (PostgreSQL or MySQL)
3. **NoSQL Database**: Firestore or MongoDB Atlas
4. **Authentication**: Identity Platform or Firebase Auth
5. **Storage**: Cloud Storage for images/files
6. **CDN**: Cloud CDN for static assets

### Deployment Steps

1. **Create GCP Project**
   ```bash
   gcloud projects create marketplace-app
   ```

2. **Set up Cloud SQL**
   ```bash
   gcloud sql instances create marketplace-db \
     --database-version POSTGRES_13 \
     --region us-central1 \
     --tier db-f1-micro
   ```

3. **Create Firestore Database**
   ```bash
   gcloud firestore databases create --region us-central1
   ```

4. **Deploy GraphQL API on Cloud Run**
   ```bash
   gcloud run deploy marketplace-api \
     --source . \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated
   ```

### Environment Variables

```bash
DATABASE_URL=postgresql://user:password@ip:5432/marketplace
FIRESTORE_PROJECT_ID=your-project-id
FIRESTORE_KEY_PATH=/path/to/serviceAccountKey.json
JWT_SECRET=your_jwt_secret_key
```

---

## Best Practices

### Data Consistency
- Keep transactional data (orders, payments, user accounts) in SQL for ACID compliance.
- Place eventually consistent data (social, reviews) in NoSQL.

### Security
- Implement authentication in the API layer.
- Use role-based access control (RBAC) for vendor/admin operations.
- Validate and sanitize all user inputs.
- Encrypt sensitive data (passwords, payment info) in transit and at rest.

### Performance
- Add database indexes on frequently queried fields (productId, userId, etc.).
- Cache frequently accessed data (product listings, popular reviews).
- Use pagination for large result sets (reviews, posts, notifications).
- Monitor query performance and optimize slow queries.

### Scalability
- Use database read replicas for read-heavy operations.
- Implement caching layer (Redis) for hot data.
- Use message queues (Pub/Sub) for asynchronous operations.
- Horizontally scale API servers behind a load balancer.

### Monitoring & Logging
- Log all API requests and errors.
- Set up alerts for database performance issues.
- Monitor API latency and response times.
- Track business metrics (orders, revenue, active users).

---

## Example: Building a Reviews/Comments Feature

### Backend Resolver (Node.js/Apollo GraphQL)

```javascript
const resolvers = {
  Product: {
    reviews: async (product, args) => {
      const db = admin.firestore();
      const snapshot = await db
        .collection('reviews')
        .where('productId', '==', product.id)
        .limit(args.limit || 10)
        .get();
      
      return snapshot.docs.map(doc => doc.data());
    }
  },
  Query: {
    product: async (_, { id }) => {
      const pool = getPostgresPool();
      const result = await pool.query('SELECT * FROM products WHERE id = $1', [id]);
      return result.rows[0];
    }
  }
};
```

### Adding a Review (Mutation)

```graphql
mutation AddReview($productId: ID!, $user: String!, $rating: Int!, $comment: String!) {
  addReview(productId: $productId, user: $user, rating: $rating, comment: $comment) {
    id
    rating
    comment
    user
    createdAt
  }
}
```

### Resolver Implementation

```javascript
const Mutation = {
  addReview: async (_, { productId, user, rating, comment }) => {
    const db = admin.firestore();
    const review = {
      productId,
      user,
      rating,
      comment,
      createdAt: new Date(),
      likes: 0
    };
    
    const docRef = await db.collection('reviews').add(review);
    return { id: docRef.id, ...review };
  }
};
```

---

## References & Further Reading

- SQL vs NoSQL in Web Applications
- GraphQL Best Practices and Architecture
- Google Cloud Platform Database Patterns
- Marketplace Database Design Patterns
- API Design for Mobile and Web Applications

---

## Revision History

- **Version 1.0** - Initial architecture document (November 2025)
  - Defined SQL vs NoSQL split for marketplace app
  - Added GraphQL integration examples
  - Included GCP deployment guidance
  - Added client implementation examples for iOS and Web
  - Provided database schema examples and best practices
