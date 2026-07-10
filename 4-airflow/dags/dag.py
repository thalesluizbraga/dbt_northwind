"""
DAG northwind_pipeline — orquestra apenas transformações dbt.

Fluxo:
  Postgres raw.* (já populado pelo ETL em 2-local_setup)
    → Cosmos DbtTaskGroup
    → dbt run/test por modelo (staging → int → marts)
"""

import os

from airflow import DAG
from cosmos import DbtTaskGroup, ExecutionConfig, ProfileConfig, ProjectConfig
from cosmos.profiles import PostgresUserPasswordProfileMapping
from pendulum import datetime

DBT_PROJECT_PATH = "/usr/local/airflow/dbt_olist"

profile_config = ProfileConfig(
    profile_name="dbt_northwind",
    target_name="dev",
    profile_mapping=PostgresUserPasswordProfileMapping(
        conn_id="northwind_postgres",
        profile_args={"schema": "public"},
    ),
)

execution_config = ExecutionConfig(
    dbt_executable_path=f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt",
)

project_config = ProjectConfig(
    dbt_project_path=DBT_PROJECT_PATH,
)

with DAG(
    dag_id="northwind_pipeline",
    schedule="@daily",
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=["northwind", "dbt"],
    default_args={"retries": 2},
) as dag:
    dbt_transform = DbtTaskGroup(
        group_id="dbt_transform",
        project_config=project_config,
        profile_config=profile_config,
        execution_config=execution_config,
        operator_args={"install_deps": True},
    )
