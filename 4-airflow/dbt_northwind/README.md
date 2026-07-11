# Espelho do projeto dbt Northwind (usado pela DAG no Airflow)

Fonte da verdade: `3-dbt/dbt_northwind/`

Ao alterar modelos na pasta de desenvolvimento, sincronize para cá:

```bash
robocopy ..\3-dbt\dbt_northwind .\dbt_northwind /E /XD target logs dbt_packages /XF run-dbt.ps1 run-dbt.sh profiles.yml .user.yml
```

Ou copie manualmente os arquivos alterados em `models/`.
