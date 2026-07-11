# Gera e serve a documentação dbt em porta separada do Airflow (8080).
# Uso: .\run-dbt-docs.ps1

$ProjectDir = $PSScriptRoot

Write-Host "Gerando documentação..." -ForegroundColor Cyan
& "$ProjectDir\run-dbt.ps1" docs generate

Write-Host "Servindo em http://localhost:$(
    if ($env:DBT_DOCS_PORT) { $env:DBT_DOCS_PORT } else { '8081' }
) (Ctrl+C para parar)" -ForegroundColor Green

& "$ProjectDir\run-dbt.ps1" docs serve
