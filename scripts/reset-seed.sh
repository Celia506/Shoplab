#!/usr/bin/env bash
# Remise a l'etat de reference SANS supprimer le conteneur : vide les tables puis rejoue le seed.
set -euo pipefail
cd "$(dirname "$0")/.."
U="${POSTGRES_USER:-shoplab}"; B="${POSTGRES_DB:-shoplab}"
docker compose exec -T db psql -q -U "$U" -d "$B" -v ON_ERROR_STOP=1 < db/outils/vider_donnees.sql
docker compose exec -T db psql -q -U "$U" -d "$B" -v ON_ERROR_STOP=1 < db/init/02_seed.sql > /dev/null
echo "Donnees ShopLab remises a l'etat du seed."
