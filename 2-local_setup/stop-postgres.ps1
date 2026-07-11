# Para o Postgres do projeto (dados preservados no volume).
# Uso: .\stop-postgres.ps1

Set-Location $PSScriptRoot
docker compose --env-file .env down
Write-Host "Postgres parado. Dados mantidos no volume postgres_data." -ForegroundColor Yellow
