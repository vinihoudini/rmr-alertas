{{
  config(
    materialized = 'view'
  )
}}

SELECT
  codigo_ibge,
  municipio,
  latitude,
  longitude
FROM {{ source('bronze', 'municipios_pe_geo') }}