# Restaure un snapshot : .\scripts\restore.ps1 <nom>
# La base est supprimee puis recreee : aucun objet cree apres le snapshot ne subsiste.
param([Parameter(Mandatory = $true)][string]$Nom)
Set-Location (Join-Path $PSScriptRoot "..")
$U = if ($env:POSTGRES_USER) { $env:POSTGRES_USER } else { "shoplab" }
$B = if ($env:POSTGRES_DB) { $env:POSTGRES_DB } else { "shoplab" }
if (-not (Test-Path "snapshots/$Nom.dump")) { Write-Host "Snapshot introuvable : snapshots/$Nom.dump"; exit 1 }
docker compose exec -T db psql -q -U $U -d postgres -v ON_ERROR_STOP=1 -c "DROP DATABASE IF EXISTS `"$B`" WITH (FORCE);" -c "CREATE DATABASE `"$B`" OWNER `"$U`";"
docker compose exec -T db pg_restore -U $U -d $B --no-owner "/snapshots/$Nom.dump"
Write-Host "Snapshot $Nom restaure."
