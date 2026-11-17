# Sauvegarde l'etat courant : .\scripts\snapshot.ps1 [nom]
param([string]$Nom = "snapshot_$(Get-Date -Format 'yyyyMMdd_HHmmss')")
Set-Location (Join-Path $PSScriptRoot "..")
$U = if ($env:POSTGRES_USER) { $env:POSTGRES_USER } else { "shoplab" }
$B = if ($env:POSTGRES_DB) { $env:POSTGRES_DB } else { "shoplab" }
docker compose exec -T db pg_dump -U $U -d $B -Fc -f "/snapshots/$Nom.dump"
Write-Host "Snapshot cree : snapshots/$Nom.dump"
