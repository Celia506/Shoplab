#!/usr/bin/env bash
# Affiche l'empreinte de la base (volumes, sommes de controle) pour verifier un etat.
set -euo pipefail
cd "$(dirname "$0")/.."
U="${POSTGRES_USER:-shoplab}"; B="${POSTGRES_DB:-shoplab}"
docker compose exec -T db psql -U "$U" -d "$B" < db/outils/empreinte.sql
