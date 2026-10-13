#!/usr/bin/env bash
# Build the iOS app's database from a release data.db: only the tables,
# columns and views the app reads (app/lib/data/queries.dart), without
# PocketBase's own tables, gzip-compressed.
# Usage: ./scripts/build-app-db.sh <data.db> <app.db.gz>

set -euo pipefail

SRC=${1:?Usage: $0 <data.db> <app.db.gz>}
OUT=${2:?Usage: $0 <data.db> <app.db.gz>}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp "$SRC" "$tmp/src.db"
cd "$tmp"

elo_tables=$(sqlite3 src.db "SELECT name FROM sqlite_master WHERE type = 'table' AND name GLOB 'elo[0-9][0-9][0-9][0-9]' ORDER BY name")

{
  cat <<'SQL'
ATTACH 'src.db' AS src;
BEGIN;
CREATE TABLE association (id TEXT PRIMARY KEY NOT NULL, name TEXT, abbreviation TEXT);
CREATE TABLE canton (id TEXT PRIMARY KEY NOT NULL, name TEXT, association TEXT);
CREATE TABLE club (id TEXT PRIMARY KEY NOT NULL, name TEXT, canton TEXT);
CREATE TABLE wrestlerStatus (id TEXT PRIMARY KEY NOT NULL, status TEXT, symbol TEXT);
CREATE TABLE wrestlerMetadata (id TEXT PRIMARY KEY NOT NULL, website TEXT, instagram TEXT);
CREATE TABLE wrestler (id TEXT PRIMARY KEY NOT NULL, name TEXT, vorname TEXT, year TEXT, club TEXT, status TEXT, metadata TEXT);
CREATE TABLE placeType (id TEXT PRIMARY KEY NOT NULL, type TEXT);
CREATE TABLE places (id TEXT PRIMARY KEY NOT NULL, name TEXT, location TEXT, year TEXT, placeType TEXT);
CREATE TABLE rankings (id TEXT PRIMARY KEY NOT NULL, place TEXT, wrestler TEXT, rank TEXT, rank2 TEXT, points TEXT,
  result TEXT, wreath BOOLEAN, final BOOLEAN, status TEXT);
CREATE TABLE bouts (place TEXT, wrestler TEXT, opponent TEXT, fight_round NUMERIC, result TEXT, points TEXT);

INSERT INTO association SELECT id, name, abbreviation FROM src.association;
INSERT INTO canton SELECT id, name, association FROM src.canton;
INSERT INTO club SELECT id, name, canton FROM src.club;
INSERT INTO wrestlerStatus SELECT id, status, symbol FROM src.wrestlerStatus;
INSERT INTO wrestlerMetadata SELECT id, website, instagram FROM src.wrestlerMetadata;
INSERT INTO wrestler SELECT id, name, vorname, year, club, status, metadata FROM src.wrestler;
INSERT INTO placeType SELECT id, type FROM src.placeType;
INSERT INTO places SELECT id, name, location, year, placeType FROM src.places;
INSERT INTO rankings SELECT id, place, wrestler, rank, rank2, points, result, wreath, final, status FROM src.rankings;
INSERT INTO bouts SELECT place, wrestler, opponent, fight_round, result, points FROM src.bouts ORDER BY wrestler, opponent;

CREATE INDEX idx_places_year ON places (year);
CREATE INDEX idx_rankings_wrestler ON rankings (wrestler);
CREATE INDEX idx_rankings_place ON rankings (place);
CREATE INDEX idx_bouts_wrestler_opponent ON bouts (wrestler, opponent);
CREATE INDEX idx_bouts_place ON bouts (place);
SQL
  for t in $elo_tables; do
    echo "CREATE TABLE $t (wrestler TEXT NOT NULL, rating NUMERIC NOT NULL);"
    echo "INSERT INTO $t SELECT wrestler, rating FROM src.$t;"
    echo "CREATE INDEX idx_${t}_wrestler ON $t (wrestler);"
  done
  sqlite3 src.db "SELECT sql || ';' FROM sqlite_master WHERE type = 'view' AND (
    name GLOB 'averageRank*' OR name GLOB 'averagePoints*' OR name GLOB 'mostWins*' OR
    name GLOB 'mostWreaths*' OR name GLOB 'mostPlacesAttended*' OR name = 'drawDecisionRatio')"
  cat <<'SQL'
COMMIT;
DETACH src;
ANALYZE;
VACUUM;
SQL
} | sqlite3 app.db

for t in wrestler places rankings bouts $elo_tables; do
  [ "$(sqlite3 app.db "SELECT count(*) FROM $t")" = "$(sqlite3 src.db "SELECT count(*) FROM $t")" ] ||
    { echo "ERROR: $t has a different row count" >&2; exit 1; }
done

cd - >/dev/null
gzip -9 -n -c "$tmp/app.db" > "$OUT"
echo "Built $OUT ($(du -h "$tmp/app.db" | cut -f1) uncompressed)"
