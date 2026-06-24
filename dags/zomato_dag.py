import os
from datetime import datetime
from datetime import timedelta

from airflow import DAG
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

from airflow.providers.standard.operators.bash import BashOperator


DBT_PROJECT_PATH = "/usr/local/airflow/dags/"

default_args = {
    'owner': 'monikroneast',
    'depends_on_past': False,   # Trigger manually for your CDC simulation testing
    'start_date': datetime(2026, 6, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id="zomato_snowflake_pipeline",
    schedule=None,
    start_date=datetime(2026, 6, 1),
    catchup=False,
    tags=["zomato", "production"]
) as dag:

    # 1. EVENT-DRIVEN GATEKEEPER: Polls S3 for new incoming JSON files
    wait_for_s3_file = S3KeySensor(
        task_id="wait_for_s3_file",
        bucket_name="amaz-s3-zomato-raw-data-landing",
        bucket_key="raw_landing/file*.json",
        wildcard_match=True,
        aws_conn_id="aws_default",
        poke_interval=30,
        mode="poke"
    )

    # 2. INGESTION LAYER: Snowflake copy command execution
    copy_s3_data_to_tables = SQLExecuteQueryOperator(
        task_id="copy_s3_to_snowflake",
        conn_id="snowflake_default",
        sql="""
            COPY INTO zomato_db.raw.staging_restaurants(raw_json)
            FROM ( SELECT $1 FROM @ZOMATO_DB.RAW.S3_STAGE )
            FILE_FORMAT = (FORMAT_NAME = zomato_db.raw.json_format)
            PURGE = TRUE;
        """
    )

    run_dbt = BashOperator(
    task_id="run_dbt_models",
    bash_command="""
    cd /home/monikroneast/zomato-modern-data-stack && dbt run --select tag:dag
    """,
    env={
        "DBT_PROFILES_DIR": "/home/monikroneast/.dbt",  # Forces dbt to use your local profiles.yml file
        "DBT_SNOWFLAKE_ACCOUNT": str(os.getenv("AIRFLOW_CONN_DBT_SNOWFLAKE_ACCOUNT") or ""),
        "DBT_SNOWFLAKE_USER": str(os.getenv("AIRFLOW_CONN_DBT_SNOWFLAKE_USER") or ""),
        "DBT_SNOWFLAKE_PASSWORD": str(os.getenv("AIRFLOW_CONN_DBT_SNOWFLAKE_PASSWORD") or ""),
        "DBT_SNOWFLAKE_ROLE": str(os.getenv("AIRFLOW_CONN_DBT_SNOWFLAKE_ROLE") or "ACCOUNTADMIN"),
        "DBT_SNOWFLAKE_WH": str(os.getenv("AIRFLOW_CONN_DBT_SNOWFLAKE_WH") or "COMPUTE_WH"),
    },
)

# Set up the sequential execution pipeline flow
wait_for_s3_file >> copy_s3_data_to_tables >> run_dbt

dag.doc_md = """
### Zomato Snowflake Data Pipeline Documentation
This DAG handles the end-to-end ELT pipeline for Zomato metrics.

#### Pipeline Steps:
1. **`wait_for_s3_file`**: Polls for new JSON files in the AWS S3 bucket to trigger the pipeline execution.
2. **`copy_s3_data_to_tables`**: Ingests raw JSON files stored in AWS S3 buckets into Snowflake target staging tables.
3. **`run_dbt_models`**: Triggers dbt models with to handle data transformation and business logic processing.
"""
