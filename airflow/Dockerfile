

FROM apache/airflow:2.9.1-python3.10

USER root

# Install git (system package)
RUN apt-get update && \
apt-get install -y git && \
apt-get clean

USER airflow

# Install dbt + snowflake adapter
RUN pip install --no-cache-dir \
dbt-core==1.8.3 \
dbt-snowflake==1.8.2





