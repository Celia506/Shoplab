#!/usr/bin/env bash
# Remise a zero COMPLETE : supprime le volume et recree la base (schema + seed).
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose down -v
docker compose up -d --wait
echo "Base ShopLab recreee a partir de db/init (schema + seed)."
