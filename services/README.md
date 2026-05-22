# Services

Backend services live here, using the `cove-<name>` convention (e.g.
`services/cove-api/`). The sibling `apps/` directory is reserved for client
applications (the iOS app today, a web client later).

The first backend service, the `cove-api` gateway, ships in Phase 1 and lives at
[`cove-api/`](cove-api/). Later phases add `cove-image`, `cove-product`, and
`cove-user` under the same `services/cove-<name>/` convention.

Each service owns its own `Dockerfile` and is built and pushed by the
`ci-services.yml` GitHub Actions workflow on changes to its path. The OpenAPI
spec for `cove-api` is the source of truth for request/response shapes and lives
at `services/cove-api/api/openapi.yaml`.

See [docs/BACKEND_INFRASTRUCTURE.md](../docs/BACKEND_INFRASTRUCTURE.md) for the
full service map, naming convention, and migration phases.
