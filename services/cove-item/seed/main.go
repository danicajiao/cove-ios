// Seed script for catalog.categories.
//
// Reads categories.yaml from the same directory and upserts every node into
// catalog.categories using a deterministic UUID derived from the ltree path.
// Safe to re-run: existing rows are updated (name only) on conflict.
//
// Usage:
//
//	go run . "postgres://app:<password>@localhost:5432/cove?sslmode=disable"
package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"runtime"

	"github.com/google/uuid"
	_ "github.com/lib/pq"
	"gopkg.in/yaml.v3"
)

// categoryNamespace is a fixed UUID v5 namespace for Cove category seeds.
// Changing this would change all generated IDs — do not modify.
var categoryNamespace = uuid.MustParse("c0ve0000-ca7e-5eed-ca7e-600000000001")

// Category mirrors one node in categories.yaml.
type Category struct {
	Name     string     `yaml:"name"`
	Path     string     `yaml:"path"`
	Children []Category `yaml:"children"`
}

// Config is the top-level structure of categories.yaml.
type Config struct {
	Categories []Category `yaml:"categories"`
}

// categoryID returns a deterministic UUID v5 for the given ltree path.
func categoryID(path string) uuid.UUID {
	return uuid.NewSHA1(categoryNamespace, []byte(path))
}

// flatten recursively collects all nodes in depth-first order.
func flatten(cats []Category) []Category {
	var out []Category
	for _, c := range cats {
		out = append(out, c)
		out = append(out, flatten(c.Children)...)
	}
	return out
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("usage: go run . <database-url>\n\nexample:\n  go run . \"postgres://app:<password>@localhost:5432/cove?sslmode=disable\"")
	}
	dbURL := os.Args[1]

	// Resolve categories.yaml relative to this file so the script can be run
	// from any working directory.
	_, thisFile, _, _ := runtime.Caller(0)
	yamlPath := filepath.Join(filepath.Dir(thisFile), "categories.yaml")

	data, err := os.ReadFile(yamlPath)
	if err != nil {
		log.Fatalf("read %s: %v", yamlPath, err)
	}

	var cfg Config
	if err := yaml.Unmarshal(data, &cfg); err != nil {
		log.Fatalf("parse categories.yaml: %v", err)
	}

	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatalf("open db: %v", err)
	}
	defer db.Close()

	if err := db.Ping(); err != nil {
		log.Fatalf("connect to db: %v", err)
	}

	cats := flatten(cfg.Categories)
	fmt.Printf("Seeding %d categories...\n", len(cats))

	for _, c := range cats {
		id := categoryID(c.Path)
		_, err := db.Exec(`
			INSERT INTO catalog.categories (id, name, path)
			VALUES ($1, $2, $3::ltree)
			ON CONFLICT (path) DO UPDATE SET name = EXCLUDED.name
		`, id, c.Name, c.Path)
		if err != nil {
			log.Fatalf("upsert %s: %v", c.Path, err)
		}
		fmt.Printf("  ✓ %s\n", c.Path)
	}

	fmt.Printf("\nDone — %d categories seeded.\n", len(cats))
}
