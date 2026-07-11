# Northwind — Airflow (Astro)

Orquestra transformações dbt via [Cosmos](https://astronomer.github.io/astronomer-cosmos/).

**Documentação completa:** [docs/SETUP.md](../docs/SETUP.md)

## Quick start

```bash
# 1. Postgres com dados raw.*
cd ../2-local_setup && docker compose up -d

# 2. Connection local (1ª vez)
cp airflow_settings.yaml.example airflow_settings.yaml

# 3. Airflow
cd ../4-airflow
astro dev start
```

- UI: http://localhost:8080 (`admin` / `admin`)
- DAG: `northwind_pipeline` (somente dbt, sem recarga de CSV)

## Arquivos principais

| Arquivo | Função |
|---------|--------|
| `dags/dag.py` | DAG + Cosmos DbtTaskGroup |
| `dbt_northwind/` | Espelho de `3-dbt/dbt_northwind/` |
| `Dockerfile` | venv com dbt-postgres |
| `airflow_settings.yaml` | Connection `northwind_postgres` |
