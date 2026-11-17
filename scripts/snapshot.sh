#!/usr/bin/env bash
# Sauvegarde l'etat courant de la base dans snapshots/<nom>.dump
# Usage : ./scripts/snapshot.sh [nom]     (defaut : snapshot_AAAAMMJJ_HHMMSS)
set -euo pipefail
cd "$(dirname "$0")/.."
U="${POSTGRES_USER:-shoplab}"; B="${POSTGRES_DB:-shoplab}"
NOM="${1:-snapshot_$(date +%Y%m%d_%H%M%S)}"
docker compose exec -T db pg_dump -U "$U" -d "$B" -Fc -f "/snapshots/${NOM}.dump"
echo "Snapshot cree : snapshots/${NOM}.dump"
