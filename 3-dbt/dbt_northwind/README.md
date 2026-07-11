# Projeto dbt Northwind — transformações sobre schema `raw`.

Documentação completa: [docs/SETUP.md](../../docs/SETUP.md)

## Desenvolvimento local

Sempre rode os comandos **dentro desta pasta** (`3-dbt/dbt_northwind`).

### Opção recomendada (wrapper)

```bash
# Git Bash / Linux
./run-dbt.sh debug
./run-dbt.sh run --select 1_staging
./run-dbt.sh test --select 1_staging
./run-dbt-docs.sh
```

```powershell
# PowerShell
.\run-dbt.ps1 debug
.\run-dbt.ps1 run --select 1_staging
.\run-dbt.ps1 test --select 1_staging
.\run-dbt-docs.ps1
```

### Documentação dbt (porta separada do Airflow)

O Airflow usa **http://localhost:8080**. O `dbt docs serve` também usa 8080 por padrão, então este projeto serve a doc em **http://localhost:8081** (`DBT_DOCS_PORT` no `.env`).

```powershell
.\run-dbt-docs.ps1          # gera + serve em :8081
.\run-dbt.ps1 docs serve    # só serve (também usa :8081)
```

```bash
./run-dbt-docs.sh
./run-dbt.sh docs serve
```

Para outra porta: `.\run-dbt.ps1 docs serve --port 8090`

### Opção manual

```bash
cd 3-dbt/dbt_northwind
export DBT_PROFILES_DIR=.
set -a && source ../../2-local_setup/.env && set +a   # Git Bash
dbt debug
dbt run --select 1_staging
dbt test --select 1_staging
```

> **Não rode `dbt` na raiz do repositório** — o `dbt_project.yml` fica aqui em `3-dbt/dbt_northwind/`.

## Camadas

| Pasta | Prefixo dbt | Exemplo |
|-------|-------------|---------|
| `models/1_staging/` | `stg_<source>__<entidade>` | `stg_northwind__customers` |
| `models/2_intermediate/` | `int_<entidade>` | `int_order_items` |
| `models/3_marts/` | `dim_`, `fct_`, `agg_` | `dim_customers`, `fct_order_items` |

## Sincronização com Airflow

Ao alterar modelos aqui, copie para `4-airflow/dbt_northwind/` (espelho usado pela DAG).
