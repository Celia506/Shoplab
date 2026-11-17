# Remise a l'etat de reference SANS supprimer le conteneur : vide les tables puis rejoue le seed.
Set-Location (Join-Path $PSScriptRoot "..")
$U = if ($env:POSTGRES_USER) { $env:POSTGRES_USER } else { "shoplab" }
$B = if ($env:POSTGRES_DB) { $env:POSTGRES_DB } else { "shoplab" }
Get-Content db/outils/vider_donnees.sql -Raw | docker compose exec -T db psql -q -U $U -d $B -v ON_ERROR_STOP=1
Get-Content db/init/02_seed.sql -Raw -Encoding UTF8 | docker compose exec -T db psql -q -U $U -d $B -v ON_ERROR_STOP=1 | Out-Null
Write-Host "Donnees ShopLab remises a l'etat du seed."
