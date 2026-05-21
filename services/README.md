# Services

> **Note:** Backend services do **not** live here. They live alongside the iOS
> app under `apps/`, using the `cove-<name>` convention (e.g. `apps/cove-api/`).
> This directory is reserved and currently holds only this README.

The first backend service, the `cove-api` gateway, ships in Phase 1 and lives at
[`apps/cove-api/`](../apps/cove-api/). Later phases add `cove-image`,
`cove-product`, and `cove-user` under the same `apps/cove-<name>/` convention.

Each service owns its own `Dockerfile` and is built and pushed by the
`services-ci.yml` GitHub Actions workflow on changes to its path. The OpenAPI
spec for `cove-api` is the source of truth for request/response shapes and lives
at `apps/cove-api/api/openapi.yaml`.

See [docs/BACKEND_INFRASTRUCTURE.md](../docs/BACKEND_INFRASTRUCTURE.md) for the
full service map, naming convention, and migration phases.
