from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator

default_args = {
    "owner": "capstone",
    "depends_on_past": False,
    "retries": 0,
}

with DAG(
    dag_id="capstone_amazon_dbt_pipeline",
    default_args=default_args,
    description="Capstone Amazon Review Analytics DBT Pipeline",
    start_date=datetime(2024, 1, 1),
    schedule_interval=None, # In production: "0 2 * * *"
    catchup=False,
    tags=["capstone", "dbt", "snowflake"],
) as dag:

    start = EmptyOperator(task_id="start")

    # 1️⃣ Debug Snowflake connection
    dbt_debug = BashOperator(
        task_id="dbt_debug",
        bash_command="""
        cd /opt/airflow/dbt &&
        dbt debug --profiles-dir /opt/airflow/dbt-profiles
        """
    )

    # 2️⃣ Install dbt packages
    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command="""
        cd /opt/airflow/dbt &&
        dbt deps --profiles-dir /opt/airflow/dbt-profiles
        """
    )

    # 3️⃣ Run STAGING models
    dbt_run_staging = BashOperator(
        task_id="dbt_run_staging",
        bash_command="""
        cd /opt/airflow/dbt &&
        dbt run --profiles-dir /opt/airflow/dbt-profiles --select path:models/staging
        """
    )

    # 4️⃣ Run MART models
    dbt_run_marts = BashOperator(
        task_id="dbt_run_marts",
        bash_command="""
        cd /opt/airflow/dbt &&
        dbt run --profiles-dir /opt/airflow/dbt-profiles --select path:models/marts
        """
    )

    # 5️⃣ Run Tests
    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command="""
        cd /opt/airflow/dbt &&
        dbt test --profiles-dir /opt/airflow/dbt-profiles
        """
    )

    # 6️⃣ Generate Docs
    dbt_docs_generate = BashOperator(
        task_id="dbt_docs_generate",
        bash_command="""
        cd /opt/airflow/dbt &&
        dbt docs generate --profiles-dir /opt/airflow/dbt-profiles
        """
    )

    end = EmptyOperator(task_id="end")

    start >> dbt_debug >> dbt_deps >> dbt_run_staging >> dbt_run_marts >> dbt_test >> dbt_docs_generate >> end