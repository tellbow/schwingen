#!/usr/bin/env bash
# Swap production PocketBase's data.db with a local copy, safely.
#
# Scales pocketbase to 0 (stops writes/reads to avoid a corrupt copy),
# attaches a temporary pod to the same PVC, renames the existing data.db
# aside (data.db.before-swap-<date>, matching the manual convention already
# used in the PVC), copies the local data.db in, then scales back up.
#
# Requires: kubectl pointed at the target cluster/context, local data.db's
# WAL checkpointed (no active local pocketbase process holding it open).
#
# Usage: ./scripts/swap-pocketbase-db.sh <path-to-local-data.db> [namespace] [context]
# Example:
#   ./scripts/swap-pocketbase-db.sh ./pb_data/data.db schwingen rk1

set -euo pipefail

LOCAL_DB=${1:?Usage: $0 <path-to-local-data.db> [namespace] [context]}
NAMESPACE=${2:-schwingen}
CONTEXT=${3:-rk1}
DATE_SUFFIX=$(date +%Y-%m-%d)
TMP_POD=pb-data-swap-tmp

KCTL=(kubectl --context "$CONTEXT" -n "$NAMESPACE")

if [ ! -f "$LOCAL_DB" ]; then
  echo "ERROR: '$LOCAL_DB' not found."
  exit 1
fi

if [ -f "${LOCAL_DB}-wal" ] && [ -s "${LOCAL_DB}-wal" ]; then
  echo "ERROR: ${LOCAL_DB}-wal is non-empty (uncommitted WAL data)."
  echo "Stop any local pocketbase process against this file so it checkpoints, then retry."
  exit 1
fi

echo "==> Scaling pocketbase to 0 replicas..."
"${KCTL[@]}" scale deployment pocketbase --replicas=0
if ! "${KCTL[@]}" wait --for=delete pod -l app=pocketbase --timeout=60s; then
  echo "ERROR: pocketbase pod(s) did not terminate within 60s." >&2
  echo "Refusing to touch data.db while it may still be open. Investigate, then rerun." >&2
  exit 1
fi

echo "==> Starting temporary pod on the pocketbase-data PVC..."
"${KCTL[@]}" run "$TMP_POD" --image=busybox:1.36 --restart=Never \
  --overrides="{\"spec\":{\"containers\":[{\"name\":\"$TMP_POD\",\"image\":\"busybox:1.36\",\"command\":[\"sleep\",\"3600\"],\"volumeMounts\":[{\"name\":\"pb-data\",\"mountPath\":\"/pb/pb_data\"}]}],\"volumes\":[{\"name\":\"pb-data\",\"persistentVolumeClaim\":{\"claimName\":\"pocketbase-data\"}}]}}"
"${KCTL[@]}" wait --for=condition=Ready pod/"$TMP_POD" --timeout=60s

cleanup() {
  echo "==> Cleaning up temporary pod..."
  "${KCTL[@]}" delete pod "$TMP_POD" --ignore-not-found --wait=false
}
trap cleanup EXIT

if "${KCTL[@]}" exec "$TMP_POD" -- sh -c "[ -f /pb/pb_data/data.db.before-swap-${DATE_SUFFIX} ]"; then
  echo "ERROR: /pb/pb_data/data.db.before-swap-${DATE_SUFFIX} already exists in the PVC." >&2
  echo "Refusing to overwrite an existing backup — rename/remove it first, then rerun." >&2
  echo "==> Scaling pocketbase back to 1 replica before exiting..."
  "${KCTL[@]}" scale deployment pocketbase --replicas=1
  exit 1
fi

echo "==> Backing up existing data.db to data.db.before-swap-${DATE_SUFFIX}..."
"${KCTL[@]}" exec "$TMP_POD" -- sh -c \
  "[ -f /pb/pb_data/data.db ] && mv /pb/pb_data/data.db /pb/pb_data/data.db.before-swap-${DATE_SUFFIX} || echo 'no existing data.db, skipping backup'"
"${KCTL[@]}" exec "$TMP_POD" -- sh -c \
  "rm -f /pb/pb_data/data.db-shm /pb/pb_data/data.db-wal"

echo "==> Copying local data.db into the PVC (this may take a while)..."
"${KCTL[@]}" cp "$LOCAL_DB" "$NAMESPACE/$TMP_POD:/pb/pb_data/data.db"

cleanup
trap - EXIT

echo "==> Scaling pocketbase back to 1 replica..."
"${KCTL[@]}" scale deployment pocketbase --replicas=1
"${KCTL[@]}" wait deployment/pocketbase --for=condition=available --timeout=120s

echo "==> Health check:"
"${KCTL[@]}" exec deploy/pocketbase -- wget -qO- http://localhost:8090/api/health

echo "==> Done. Old data.db backed up as data.db.before-swap-${DATE_SUFFIX} in the PVC."
