# Infraestrutura local — Postgres + ETL

Sobe o banco usado pelo **dbt**, **Power BI** e **Airflow**.

## Pré-requisito

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado e **em execução** (ícone da baleia na bandeja do sistema).

## Ativar o Postgres

### Opção recomendada (scripts)

```powershell
# PowerShell — na pasta 2-local_setup
.\start-postgres.ps1
```

```bash
# Git Bash
./start-postgres.sh
```

### Opção manual

```bash
cd 2-local_setup
docker compose --env-file .env up -d
```

## Verificar se está rodando

```bash
docker compose ps
```

Saída esperada: container `dbt_postgres` com status **running (healthy)**.

Teste rápido de conexão:

```powershell
docker exec dbt_postgres pg_isready -U postgres -d dbt_db
```

## Parar o Postgres

```powershell
.\stop-postgres.ps1
```

ou:

```bash
docker compose --env-file .env down
```

> `down` para o container, mas **mantém os dados** no volume `postgres_data`.

## Conexão (dbt / Power BI / DBeaver)

| Campo    | Valor       |
|----------|-------------|
| Host     | `localhost` |
| Porta    | `5433`      |
| Banco    | `dbt_db`    |
| Usuário  | `postgres`  |
| Senha    | `postgres`  |
| Schema   | `public`    |

A porta **5433** evita conflito com o Postgres interno do Airflow (5432).

## Carga inicial dos CSVs (1x ou após reset do volume)

```bash
uv sync
uv run python -m etl.load_raw
```

## Fluxo completo do zero

```bash
cd 2-local_setup
docker compose --env-file .env up -d    # 1. sobe Postgres
uv sync                                  # 2. ambiente Python
uv run python -m etl.load_raw            # 3. CSV → schema raw
cd ../3-dbt/dbt_northwind
.\run-dbt.ps1 run                        # 4. materializa modelos
.\run-dbt.ps1 test                       # 5. testes
```

## Troubleshooting

| Sintoma | Causa | Solução |
|---------|-------|---------|
| `docker: command not found` | Docker não instalado | Instale o Docker Desktop |
| `Cannot connect to Docker daemon` | Docker Desktop parado | Abra o Docker Desktop e aguarde iniciar |
| `port is already allocated` | Porta 5433 em uso | Pare o outro serviço ou altere a porta no `.env` e `docker-compose.yml` |
| Power BI não conecta | Container parado | Rode `.\start-postgres.ps1` |
| Tabelas `dim_*` / `fct_*` vazias | dbt não rodou | `cd 3-dbt/dbt_northwind` → `.\run-dbt.ps1 run` |
