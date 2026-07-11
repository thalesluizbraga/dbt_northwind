# Sobe o Postgres do projeto Northwind.
# Uso: .\start-postgres.ps1

$SetupDir = $PSScriptRoot
$EnvFile = Join-Path $SetupDir ".env"

if (-not (Test-Path $EnvFile)) {
    Write-Error "Arquivo .env não encontrado em $SetupDir"
    exit 1
}

Write-Host "Verificando Docker..." -ForegroundColor Cyan
docker info *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker não está rodando. Abra o Docker Desktop e tente novamente."
    exit 1
}

Set-Location $SetupDir
Write-Host "Subindo Postgres (dbt_postgres) na porta 5433..." -ForegroundColor Cyan
docker compose --env-file .env up -d

Start-Sleep -Seconds 5
docker compose ps

Write-Host ""
Write-Host "Conexão:" -ForegroundColor Green
Write-Host "  Host: localhost | Porta: 5433 | Banco: dbt_db | User: postgres | Senha: postgres"
