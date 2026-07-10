#!/usr/bin/env bash
# Wrapper para rodar dbt no projeto Northwind com profile e .env corretos.
# Uso: ./run-dbt.sh debug
#      ./run-dbt.sh run --select 1_staging
#      ./run-dbt.sh test --select 1_staging

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$PROJECT_DIR/../../2-local_setup/.env"
DBT_BIN="$PROJECT_DIR/../../2-local_setup/.venv/Scripts/dbt.exe"

if [[ ! -f "$DBT_BIN" ]]; then
  echo "dbt não encontrado em $DBT_BIN. Rode 'uv sync' em 2-local_setup." >&2
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Arquivo .env não encontrado em $ENV_FILE" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source <(grep -v '^#' "$ENV_FILE" | sed 's/\r$//')
set +a

export DBT_PROFILES_DIR="$PROJECT_DIR"
cd "$PROJECT_DIR"
exec "$DBT_BIN" "$@"
