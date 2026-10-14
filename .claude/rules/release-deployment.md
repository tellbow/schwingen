# Releases & Deployment

## Where things live

- **Manifests:** `tellbow/gitops` → `cluster/schwingen/` (Flux, SOPS-encrypted `secret.yaml`). Never add Kubernetes manifests to this repo.
- **Image policies:** `tellbow/gitops` → `cluster/flux-system/image-automation/schwingen.yaml` (`schwingen-frontend`, `schwingen-pocketbase`, semver).
- **Data pipeline:** `tellbow/schwingen-data` imports into a *local* PocketBase. Production is never written to.
- **Images:** `ghcr.io/tellbow/schwingen-frontend`, `ghcr.io/tellbow/schwingen-pocketbase`
- **Bug reports (#45):** issues in the private `tellbow/schwingen-feedback`; the frontend gets `GITHUB_FEEDBACK_TOKEN` (fine-grained, Issues read/write on that repo only, from `schwingen-secret`) and `GITHUB_FEEDBACK_REPO` (`frontend-deployment.yaml`).

## Release flow

1. The user pushes a signed tag (`git tag -s vX.Y.Z`, key in `.github/release-signers.asc`), creates the GitHub release from it and uploads `data.db` by hand.
2. `release.yml` verifies the tag signature, strips auth records from the asset (`scripts/strip-auth-records.sh`), attaches `app.db.gz` for the iOS app (`scripts/build-app-db.sh`) and pushes both images tagged `X.Y.Z` and `sha-<commit>`, with SBOM, provenance and a keyless cosign signature.
3. Flux image automation bumps both deployments to `X.Y.Z`.
4. The pocketbase initContainer compares the latest release tag with `pb_data/.release` and swaps in the new `data.db` when it differs (old one kept as `data.db.previous`).

Every release rebuilds both images, even a data-only release — the image bump is what restarts the pod and pulls the new `data.db`.

## Rules

- **No accounts in a published `data.db`** — `_superusers`, `users`, `_externalAuths`, `_mfas`, `_otps`, `_authOrigins` must be empty. Production runs without a superuser.
- **Schema changes are migrations** in `pb_migrations/` — they ship in the pocketbase image and run on start, on top of whatever `data.db` the release carries.
- **Local `PB_ENCRYPTION_KEY` = production key** — `data.db` settings are encrypted with it; a mismatch stops PocketBase from starting.
- **Local PocketBase version = image version** (`PB_VERSION` in `docker/pocketbase/Dockerfile`). A `data.db` written by a newer PocketBase may not open in the image.
- **Pin GitHub Actions by commit SHA** with the version as a trailing comment.
- **Don't push `latest` or deploy by mutable tag** — Flux tracks semver tags only.
- Releases, tags and pushes to `tellbow/gitops` are outward-facing: confirm with the user before creating them.
