# Affiche l'empreinte de la base pour verifier un etat.
Set-Location (Join-Path $PSScriptRoot "..")
$U = if ($env:POSTGRES_USER) { $env:POSTGRES_USER } else { "shoplab" }
$B = if ($env:POSTGRES_DB) { $env:POSTGRES_DB } else { "shoplab" }
Get-Content db/outils/empreinte.sql -Raw | docker compose exec -T db psql -U $U -d $B
