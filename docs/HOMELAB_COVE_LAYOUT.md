# Cove Infrastructure Layout in Homelab

> Cove's backend services and the platform operators they depend on live in the [`homelab`](https://github.com/danicajiao/homelab) repo, alongside other K3s tenants. This doc is a pointer; runbooks and operational details live in `homelab/docs/`.

## Why homelab and not a dedicated repo

Originally planned as a separate `cove-infra` repo, then consolidated into homelab because:

- **One cluster → one GitOps source of truth.** Splitting GitOps for the same cluster across two repos creates coordination headaches around shared platform components.
- **Shared platform operators deduplicate across tenants.** Argo CD, External Secrets Operator, CloudNativePG, Garage, the observability stack — all installed once, used by every tenant.
- **Argo CD bootstrap is a one-time, cluster-wide concern**, not a per-product one.

If Cove ever migrates off the home K3s cluster (e.g., to GKE), the `apps/cove/` subtree and the cove-relevant pieces of `infra/` carve out cleanly into a new repo. No design choice today blocks that path.

## Where Cove sits in homelab

```
homelab/
├── apps/
│   ├── gaming/
│   │   └── minecraft/                    # separate tenant, not Cove
│   └── cove/
│       ├── base/                         # cove-api (P1), cove-image + imgproxy (P2), cove-item + cove-user (P3), cove-db (CNPG cluster); each in its own subdir
│       └── overlays/
│           ├── staging/                  # → cove-staging namespace
│           └── prod/                     # → cove-prod namespace
├── infra/                                # cluster-wide platform operators
│   ├── argocd/
│   ├── external-secrets/
│   ├── cnpg/
│   ├── garage/
│   ├── kube-prometheus-stack/
│   ├── loki/
│   ├── alloy/
│   └── cloudflare-tunnel/
└── argocd/                               # Argo CD Application manifests (app-of-apps roots)
    ├── root.yaml                         # applied directly; not listed in kustomization.yaml
    ├── kustomization.yaml                # lists every child Application below
    ├── argocd-self.yaml
    ├── cert-manager.yaml
    ├── external-secrets.yaml
    ├── cnpg.yaml
    ├── cnpg-barman-plugin.yaml
    ├── garage.yaml
    ├── kube-prometheus-stack.yaml
    ├── loki.yaml
    ├── alloy.yaml
    ├── cloudflare-tunnel.yaml
    ├── minecraft.yaml
    ├── apps-cove-staging.yaml
    └── apps-cove-prod.yaml
```

`apps/` is per-tenant per-environment. `infra/` is cluster-singleton platform components. `argocd/` is the app-of-apps tree Argo CD reconciles against.

## Service source (in the cove monorepo)

Backend services live in the `danicajiao/cove` monorepo under `services/cove-<name>/`, **not** in separate repos. The `ci-services.yml` workflow builds each service's container image and pushes it to GAR; `homelab` declares how those images run.

| Service | Path in `danicajiao/cove` | Phase | Deployment | Implementation issue |
|---|---|---|---|---|
| `cove-api` | `services/cove-api/` | 1 | staging + prod | [danicajiao/cove#229](https://github.com/danicajiao/cove/issues/229) |
| `cove-image` | `services/cove-image/` | 2 | staging + prod | [danicajiao/cove#238](https://github.com/danicajiao/cove/issues/238) |
| `imgproxy` | upstream image; HMAC signing helper in `packages/imgproxy/` | 2 | staging + prod | — |
| `cove-item` | `services/cove-item/` | 3 | staging (prod on merge to `main`) | [danicajiao/cove#321](https://github.com/danicajiao/cove/issues/321) |
| `cove-user` | `services/cove-user/` | 3 | staging (prod on merge to `main`) | [danicajiao/cove#322](https://github.com/danicajiao/cove/issues/322) |

`cove-api` shipped in Phase 1; `cove-image` and `imgproxy` in Phase 2; `cove-item` and `cove-user` in Phase 3 (live in `cove-staging`, promoted to `cove-prod` when the Phase 3 integration branch merges to `main`). The `cove-api` and `cove-image` issue links predate the monorepo decision and reference the original separate-repo planning tickets.

## Runbooks

Operational docs live in [`homelab/docs/`](https://github.com/danicajiao/homelab/tree/main/docs):

| Runbook | Covers |
|---|---|
| `argocd-install.md` | Argo CD bootstrap, app-of-apps pattern, day-2 ops |
| `cnpg-install.md` | CloudNativePG operator install and cluster provisioning |
| `external-secrets-install.md` | External Secrets Operator setup and secret stores |
| `garage-install.md` | Garage S3-compatible object storage install |
| `kube-prometheus-stack-install.md` | Prometheus + Grafana monitoring stack |
| `loki-install.md` | Loki log aggregation install |
| `node-setup.md` | K3s node provisioning and prerequisites |
| `commands.md` | Common cluster operations cheat sheet |

## See also

- [Backend Infrastructure](BACKEND_INFRASTRUCTURE.md) — overall stack and migration phases
- [iOS App Architecture](IOS_APP_ARCHITECTURE.md) — current iOS app structure
