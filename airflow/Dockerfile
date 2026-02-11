FROM apache/airflow:2.9.1-python3.10

USER airflow 

# root

# Install dbt + snowflake adapter
RUN pip install --no-cache-dir \
    dbt-core==1.8.3 \
    dbt-snowflake==1.8.2

USER airflow





