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
```

```powershell
# PowerShell
.\run-dbt.ps1 debug
.\run-dbt.ps1 run --select 1_staging
.\run-dbt.ps1 test --select 1_staging
```

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

| Pasta | Materialização | Função |
|-------|----------------|--------|
| `models/1_staging/` | view | Limpeza de `raw.*` |
| `models/2_intermediate/` | view | Joins e enriquecimento |
| `models/3_marts/` | table | Dimensões e fatos para BI |

## Sincronização com Airflow

Ao alterar modelos aqui, copie para `4-airflow/dbt_northwind/` (espelho usado pela DAG).
