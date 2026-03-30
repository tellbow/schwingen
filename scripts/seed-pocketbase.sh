#!/usr/bin/env bash
# Seed PocketBase data into a running Kubernetes pod.
# Usage: ./scripts/seed-pocketbase.sh [namespace] [local-pb-data-dir]
#
# Example:
#   ./scripts/seed-pocketbase.sh schwingen ./pb_data

set -euo pipefail

NAMESPACE=${1:-schwingen}
LOCAL_PB_DATA=${2:-./pb_data}

if [ ! -d "$LOCAL_PB_DATA" ]; then
  echo "ERROR: Directory '$LOCAL_PB_DATA' not found."
  exit 1
fi

echo "Waiting for pocketbase pod to be ready..."
kubectl -n "$NAMESPACE" wait deployment/pocketbase --for=condition=available --timeout=120s

POD=$(kubectl -n "$NAMESPACE" get pods -l app=pocketbase -o jsonpath='{.items[0].metadata.name}')
echo "Seeding into pod: $POD"

echo "Copying pb_data to pod (this may take a while for large databases)..."
kubectl -n "$NAMESPACE" cp "$LOCAL_PB_DATA" "$POD:/pb/pb_data_new"

echo "Stopping PocketBase to swap data..."
kubectl -n "$NAMESPACE" exec "$POD" -- sh -c 'kill 1' || true

# The pod will restart; new data will be in place on next start
# (You may need to move files into the correct location first)
kubectl -n "$NAMESPACE" exec "$POD" -- sh -c \
  'cp -r /pb/pb_data_new/. /pb/pb_data/ && rm -rf /pb/pb_data_new' 2>/dev/null || \
  echo "Note: pod restarted before copy finished. Re-run if needed."

echo "Done. Restart the pod to apply:"
echo "  kubectl -n $NAMESPACE rollout restart deployment/pocketbase"
