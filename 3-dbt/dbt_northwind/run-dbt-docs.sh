#!/usr/bin/env bash
# Gera e serve a documentação dbt em porta separada do Airflow (8080).
# Uso: ./run-dbt-docs.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Gerando documentação..."
"$PROJECT_DIR/run-dbt.sh" docs generate

DOCS_PORT="${DBT_DOCS_PORT:-8081}"
echo "Servindo em http://localhost:${DOCS_PORT} (Ctrl+C para parar)"
exec "$PROJECT_DIR/run-dbt.sh" docs serve
