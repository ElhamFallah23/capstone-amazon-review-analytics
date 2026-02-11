from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator


# -------------------------------------------------------------------
# Default arguments
# -------------------------------------------------------------------
default_args = {
    "owner": "capstone",
    "depends_on_past": False,
    "retries": 0,
}

# -------------------------------------------------------------------
# DAG definition
# -------------------------------------------------------------------
with DAG(
    dag_id="capstone_amazon_dbt_pipeline",
    default_args=default_args,
    description="Capstone Amazon Review Analytics DBT Pipeline",
    start_date=datetime(2024, 1, 1),
    schedule_interval=None, # Manual trigger (production: can be daily)
    catchup=False,
    tags=["capstone", "dbt", "snowflake"],
) as dag:

    # ---------------------------
    # Start
    # ---------------------------
    start = EmptyOperator(task_id="start")

    # ---------------------------
    # Install dbt packages
    # ---------------------------
    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command="""
        cd /opt/airflow/dbt &&
        dbt run --profiles-dir /opt/airflow/dbt-profiles
        """
    )

    # ---------------------------
    # Run STAGING models
    # ---------------------------
    dbt_run_staging = BashOperator(
        task_id="dbt_run_staging",
        bash_command="""
        cd /opt/airflow/dbt &&
        dbt deps --profiles-dir /opt/airflow/dbt-profiles
        """
    )

    # ---------------------------
    # Run MART models
    # ---------------------------
    dbt_run_mart = BashOperator(
        task_id="dbt_run_mart",
        bash_command="""
        cd /opt/airflow/dbt &&
        dbt run --profiles-dir /opt/airflow/dbt-profiles --select path:models/mart
        """
    )

    # ---------------------------
    # Run DBT Tests
    # ---------------------------
    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command="""
        cd /opt/airflow/dbt &&
        dbt run --profiles-dir /opt/airflow/dbt-profiles
        """
    )

    # ---------------------------
    # End
    # ---------------------------
    end = EmptyOperator(task_id="end")

    # ---------------------------
    # DAG Order
    # ---------------------------
    start >> dbt_deps >> dbt_run_staging >> dbt_run_mart >> dbt_test >> end
