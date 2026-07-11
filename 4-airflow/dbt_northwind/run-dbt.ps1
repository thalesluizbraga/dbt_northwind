# Wrapper para rodar dbt no projeto Northwind com profile e .env corretos.
# Uso: .\run-dbt.ps1 debug
#      .\run-dbt.ps1 run --select 1_staging
#      .\run-dbt.ps1 test --select 1_staging
#      .\run-dbt.ps1 docs serve          # usa porta 8081 (DBT_DOCS_PORT) para não conflitar com Airflow

param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$DbtArgs
)

$ProjectDir = $PSScriptRoot
$EnvFile = Join-Path $ProjectDir "..\..\2-local_setup\.env"
$ProfilesDir = $ProjectDir
$VenvDbt = Join-Path $ProjectDir "..\..\2-local_setup\.venv\Scripts\dbt.exe"

if (-not (Test-Path $VenvDbt)) {
    Write-Error "dbt não encontrado em $VenvDbt. Rode 'uv sync' em 2-local_setup."
    exit 1
}

if (-not (Test-Path $EnvFile)) {
    Write-Error "Arquivo .env não encontrado em $EnvFile"
    exit 1
}

Get-Content $EnvFile | ForEach-Object {
    if ($_ -match '^([^#=]+)=(.*)$') {
        [System.Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), 'Process')
    }
}

$env:DBT_PROFILES_DIR = $ProfilesDir
Set-Location $ProjectDir

$isDocsServe = ($DbtArgs.Count -ge 2 -and $DbtArgs[0] -eq "docs" -and $DbtArgs[1] -eq "serve")
$hasPortFlag = $DbtArgs -contains "--port"

if ($isDocsServe -and -not $hasPortFlag) {
    $docsPort = if ($env:DBT_DOCS_PORT) { $env:DBT_DOCS_PORT } else { "8081" }
    Write-Host "dbt docs serve na porta $docsPort (Airflow usa 8080)" -ForegroundColor Cyan
    & $VenvDbt @DbtArgs --port $docsPort
} else {
    & $VenvDbt @DbtArgs
}
