# Remise a zero COMPLETE : supprime le volume et recree la base (schema + seed).
Set-Location (Join-Path $PSScriptRoot "..")
docker compose down -v
docker compose up -d --wait
Write-Host "Base ShopLab recreee a partir de db/init (schema + seed)."
