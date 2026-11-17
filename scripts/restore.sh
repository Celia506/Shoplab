#!/usr/bin/env bash
# Restaure un snapshot : ./scripts/restore.sh <nom>   (fichier snapshots/<nom>.dump)
# La base est supprimee puis recreee : aucun objet cree apres le snapshot ne subsiste.
set -euo pipefail
cd "$(dirname "$0")/.."
U="${POSTGRES_USER:-shoplab}"; B="${POSTGRES_DB:-shoplab}"
NOM="${1:?Usage : ./scripts/restore.sh <nom_du_snapshot>}"
test -f "snapshots/${NOM}.dump" || { echo "Snapshot introuvable : snapshots/${NOM}.dump"; exit 1; }
docker compose exec -T db psql -q -U "$U" -d postgres -v ON_ERROR_STOP=1 \
  -c "DROP DATABASE IF EXISTS \"$B\" WITH (FORCE);" -c "CREATE DATABASE \"$B\" OWNER \"$U\";"
docker compose exec -T db pg_restore -U "$U" -d "$B" --no-owner "/snapshots/${NOM}.dump"
echo "Snapshot ${NOM} restaure."
