# Wrapper para rodar dbt no projeto Northwind com profile e .env corretos.
# Uso: .\run-dbt.ps1 debug
#      .\run-dbt.ps1 run --select 1_staging
#      .\run-dbt.ps1 test --select 1_staging

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

& $VenvDbt @DbtArgs
