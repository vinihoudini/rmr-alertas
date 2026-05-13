{{
  config(
    materialized = 'table',
    schema = 'silver',
    tags = ['mapeamento', 'estacoes']
  )
}}

WITH fonte_api AS (
  -- Lê todos os arquivos Parquet da coleta de 15 minutos
  SELECT
    codigo_gmmc,
    UPPER(TRIM(cidade)) AS municipio_nome,
    nome_estacao,
    latitude,
    longitude,
    ROW_NUMBER() OVER (
      PARTITION BY codigo_gmmc
      ORDER BY data_hora DESC
    ) AS rn
  FROM {{ ref('brz_api_cemaden') }}
  WHERE cidade IS NOT NULL
),

estacoes_dedup AS (
  SELECT
    codigo_gmmc,
    municipio_nome,
    nome_estacao,
    latitude,
    longitude
  FROM fonte_api
  WHERE rn = 1
)

SELECT
  e.codigo_gmmc AS estacao_codigo,
  e.nome_estacao,
  e.municipio_nome,
  ibge.codigo_ibge,
  e.latitude,
  e.longitude,
  CURRENT_TIMESTAMP AS atualizado_em
FROM estacoes_dedup e
LEFT JOIN {{ ref('stg_ibge_municipios_pe') }} ibge
  ON e.municipio_nome = UPPER(TRIM(ibge.municipio))