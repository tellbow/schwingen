#!/usr/bin/env bash
# Remove every account and login record from a PocketBase data.db, in place,
# so the file can be published as a release asset.
# Usage: ./scripts/strip-auth-records.sh <path-to-data.db>
#
# Publish a copy, never the local working database:
#   cp pb_data/data.db /tmp/data.db && ./scripts/strip-auth-records.sh /tmp/data.db

set -euo pipefail

DB=${1:?Usage: $0 <path-to-data.db>}
TABLES=(_superusers users _externalAuths _mfas _otps _authOrigins)

for t in "${TABLES[@]}"; do
  sqlite3 "$DB" "DELETE FROM \`$t\`;"
done
sqlite3 "$DB" "PRAGMA journal_mode=DELETE; VACUUM;" >/dev/null

for t in "${TABLES[@]}"; do
  n=$(sqlite3 "$DB" "SELECT count(*) FROM \`$t\`;")
  [ "$n" = 0 ] || { echo "ERROR: $t still has $n rows" >&2; exit 1; }
done
echo "Stripped auth records from $DB"
