#!/usr/bin/env bash
# Rebuild the Chai Corner database from zero: base file + every lesson's setup.sql in course order.
# WARNING: drops the chai_corner database first.
set -euo pipefail
PGUSER="${PGUSER:-postgres}"
PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
DB=chai_corner
export PGUSER PGHOST PGPORT
cd "$(dirname "$0")"
ROOT="$(cd .. && pwd)"
if [ -z "${PGPASSWORD:-}" ]; then
  read -r -s -p "PostgreSQL password for $PGUSER: " PGPASSWORD; echo
  export PGPASSWORD
fi
psql -v ON_ERROR_STOP=1 -d postgres -q -c "DROP DATABASE IF EXISTS $DB" -c "CREATE DATABASE $DB"
psql -v ON_ERROR_STOP=1 -d "$DB" -q -f chai_corner.sql
while read -r lesson; do
  [ -z "$lesson" ] && continue
  echo "== $lesson"
  (cd "$ROOT/$lesson" && psql -v ON_ERROR_STOP=1 -d "$DB" -q -f setup.sql)
done < setup_order.txt
echo "Done: chai_corner is ready for every lesson."
