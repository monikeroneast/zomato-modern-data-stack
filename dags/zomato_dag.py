import os
from datetime import datetime
from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.operators.bash import BashOperator

DBT_PROJECT_PATH = "/usr/local/airflow/dags/zomato-modern-data-stack"

with DAG(
    dag_id="zomato_snowflake_pipeline",
    schedule=None,
    start_date=datetime(2026, 6, 1),
    catchup=False,
    tags=["zomato", "production"]
) as dag:

    copy_s3_data_to_tables = SQLExecuteQueryOperator(
        task_id="copy_s3_to_snowflake",
        conn_id="snowflake_default",
        sql="""
            COPY INTO zomato_db.raw.staging_restaurants
            FROM @zomato_db.raw.s3_stage
            FILE_FORMAT = (FORMAT_NAME = zomato_db.raw.json_format)
            MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
        """
    )

    run_dbt = BashOperator(
    task_id="run_dbt_models",
    bash_command="cd /usr/local/airflow/dags/zomato-modern-data-stack/dbt_project && dbt seed --profiles-dir .. && dbt run --profiles-dir ..",
    # Use str() casting or empty string fallbacks so Python never throws a NoneType exception
        env={
            "DBT_SNOWFLAKE_ACCOUNT": str(os.getenv("AIRFLOW__CONN__DBT_SNOWFLAKE_ACCOUNT") or ""),
            "DBT_SNOWFLAKE_USER": str(os.getenv("AIRFLOW__CONN__DBT_SNOWFLAKE_USER") or ""),
            "DBT_SNOWFLAKE_PASSWORD": str(os.getenv("AIRFLOW__CONN__DBT_SNOWFLAKE_PASSWORD") or ""),
            "DBT_SNOWFLAKE_ROLE": str(os.getenv("AIRFLOW__CONN__DBT_SNOWFLAKE_ROLE") or "ACCOUNTADMIN"),
            "DBT_SNOWFLAKE_WH": str(os.getenv("AIRFLOW__CONN__DBT_SNOWFLAKE_WH") or "COMPUTE_WH"),
        },
    )


    copy_s3_data_to_tables >> run_dbt