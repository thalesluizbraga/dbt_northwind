#!/usr/bin/env bash
# Sobe o Postgres do projeto Northwind.
# Uso: ./start-postgres.sh

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SETUP_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Arquivo .env não encontrado em $SETUP_DIR" >&2
  exit 1
fi

echo "Verificando Docker..."
if ! docker info >/dev/null 2>&1; then
  echo "Docker não está rodando. Abra o Docker Desktop e tente novamente." >&2
  exit 1
fi

cd "$SETUP_DIR"
echo "Subindo Postgres (dbt_postgres) na porta 5433..."
docker compose --env-file .env up -d

sleep 5
docker compose ps

echo ""
echo "Conexão:"
echo "  Host: localhost | Porta: 5433 | Banco: dbt_db | User: postgres | Senha: postgres"
