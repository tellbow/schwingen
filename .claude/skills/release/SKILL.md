---
name: release
description: Releases Tellbow to production - signed tag vX.Y.Z on main, GitHub release with data.db, waits for the image build, lets Flux deploy it and checks it. Only when the user asks for a release.
disable-model-invocation: true
---

# Release

A release deploys code and data to production
(https://schwingen.tellbow.ch). Confirm the version with the user before
tagging: fixes and new data raise the patch number, new features the minor
one. `.claude/rules/release-deployment.md` has the rules.

1. **Ready?** `main` is pushed and CI passed for its last commit:
   `gh run list -L 1 --branch main`. The local PocketBase has the data to
   ship (imported from `tellbow/schwingen-data`), runs the version of
   `PB_VERSION` in `docker/pocketbase/Dockerfile`, and its
   `PB_ENCRYPTION_KEY` is the production key.
2. **Tag:**
   `git tag -s vX.Y.Z -m "Tellbow X.Y.Z: <what, in a few words>" <sha>`
   (signed with the GPG key that signs the commits; the `release` workflow
   refuses a tag it cannot verify against `.github/release-signers.asc`).
   Pushing is denied to Claude: the user runs
   `! git push origin vX.Y.Z`.
3. **data.db:** a stripped copy, never the working database. The dev server
   may be running, so copy with SQLite's backup, not `cp`:
   `sqlite3 pb_data/data.db ".backup '<scratchpad>/data.db'"`, then
   `./scripts/strip-auth-records.sh <scratchpad>/data.db`. The asset is
   public as soon as the release is published, before the workflow strips
   it again. A release without new data needs no `data.db`; the cluster
   keeps its current database.
4. **GitHub release:** the user creates it from the tag and attaches the
   stripped `data.db`, by hand or with
   `! gh release create vX.Y.Z <scratchpad>/data.db --verify-tag --title "Tellbow X.Y.Z" --notes "<what changed>"`.
   Publishing it starts the `release` workflow.
5. **Images:** the workflow verifies the tag, strips the asset, attaches
   `app.db.gz` for the iOS app (check with `gh release view vX.Y.Z`) and builds
   `ghcr.io/tellbow/schwingen-{frontend,pocketbase}` as `X.Y.Z`.
   `gh run list -L 2 --workflow release.yml` for its id, then
   `gh run watch <id> --exit-status`.
6. **Deploy:** Flux image automation sets both tags in the gitops repo
   (`cluster/schwingen`). Never edit them by hand: the automation reverts
   manual bumps. With `KUBECONFIG=~/.kube/k3s.yaml` and `--context rk1`:
   - `flux reconcile image repository schwingen-frontend` (and `schwingen-pocketbase`)
   - `flux reconcile image update flux-system`
   - `flux reconcile kustomization flux-system --with-source`
7. **Check** (same `KUBECONFIG`):
   - `kubectl --context rk1 -n schwingen rollout status deploy/frontend` and `deploy/pocketbase`
     (the pocketbase initContainer `fetch-data` swaps in the new `data.db`;
     migrations run on start)
   - both run `X.Y.Z`:
     `kubectl --context rk1 -n schwingen get deploy -o jsonpath='{range .items[*]}{.metadata.name} {.spec.template.spec.containers[0].image}{"\n"}{end}'`
   - `https://schwingen.tellbow.ch/health` answers, and the new data shows
     on the site
   - the logs have no errors:
     `kubectl --context rk1 -n schwingen logs deploy/pocketbase --since=10m`
     and `-c fetch-data` for the swap, `deploy/frontend` likewise
