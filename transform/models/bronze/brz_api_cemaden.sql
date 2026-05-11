{{
  config(
    materialized = 'view',
    tags = ['api', 'cemaden', 'bronze']
  )
}}

SELECT
  *
FROM read_parquet(
  '../include/data/raw/api_cemaden/*/*/*/*.parquet',
  hive_partitioning = true
)
