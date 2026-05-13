{{
  config(
    materialized = 'table',
    schema = 'silver'
  )
}}

WITH base_ibge AS (
  SELECT
    codigo_ibge,
    municipio,
    latitude,
    longitude,
    {{ clean_string('municipio') }} as municipio_limpo
  FROM {{ ref('stg_ibge_municipios_pe') }}
),

distinct_postos AS (
  SELECT DISTINCT
    codigo_posto,
    nome_posto,
    {{ clean_string('nome_posto') }} as nome_posto_limpo
  FROM {{ source('bronze', 'monitoramento_pluviometrico') }}
),

match_exato AS (
  SELECT
    p.codigo_posto,
    i.municipio AS municipio_inferido,
    i.latitude,
    i.longitude,
    'Exato' AS tipo_match
  FROM distinct_postos p
  INNER JOIN base_ibge i ON p.nome_posto_limpo = i.municipio_limpo
),

postos_restantes_1 AS (
  SELECT * FROM distinct_postos
  WHERE codigo_posto NOT IN (SELECT codigo_posto FROM match_exato)
),

match_comeca_com AS (
  SELECT
    p.codigo_posto,
    i.municipio AS municipio_inferido,
    i.latitude,
    i.longitude,
    'Comeca_Com' AS tipo_match
  FROM postos_restantes_1 p
  INNER JOIN base_ibge i ON p.nome_posto_limpo LIKE i.municipio_limpo || '%'
),

postos_restantes_2 AS (
  SELECT * FROM postos_restantes_1
  WHERE codigo_posto NOT IN (SELECT codigo_posto FROM match_comeca_com)
),

match_contem AS (
  SELECT
    p.codigo_posto,
    i.municipio AS municipio_inferido,
    i.latitude,
    i.longitude,
    'Contem' AS tipo_match
  FROM postos_restantes_2 p
  INNER JOIN base_ibge i ON p.nome_posto_limpo LIKE '%' || i.municipio_limpo || '%'
),

postos_sem_match AS (
  SELECT
    p.codigo_posto,
    CAST(NULL AS VARCHAR) AS municipio_inferido,
    CAST(NULL AS DOUBLE) AS latitude,
    CAST(NULL AS DOUBLE) AS longitude,
    'Sem_Match' AS tipo_match
  FROM postos_restantes_2 p
  WHERE codigo_posto NOT IN (SELECT codigo_posto FROM match_contem)
),

mapeamento_final AS (
  SELECT * FROM (
    SELECT * FROM match_exato
    UNION ALL
    SELECT * FROM match_comeca_com
    UNION ALL
    SELECT * FROM match_contem
    UNION ALL
    SELECT * FROM postos_sem_match
  ) sub
  QUALIFY ROW_NUMBER() OVER (PARTITION BY codigo_posto ORDER BY tipo_match) = 1
),

dados_base AS (
  SELECT
    m.codigo_posto,
    m.nome_posto,
    m.data,
    EXTRACT(YEAR FROM m.data) AS ano,
    EXTRACT(MONTH FROM m.data) AS mes,
    EXTRACT(DAY FROM m.data) AS dia,
    CASE DAYOFWEEK(m.data)
      WHEN 0 THEN 'Domingo'
      WHEN 1 THEN 'Segunda-feira'
      WHEN 2 THEN 'Terça-feira'
      WHEN 3 THEN 'Quarta-feira'
      WHEN 4 THEN 'Quinta-feira'
      WHEN 5 THEN 'Sexta-feira'
      WHEN 6 THEN 'Sábado'
    END AS dia_semana,
    m.precipitacao,
    m.mesorregiao_id,
    CASE
      WHEN m.mesorregiao_id IN (2601, 2602) THEN
        CASE WHEN EXTRACT(MONTH FROM m.data) BETWEEN 1 AND 4 THEN 'Chuvoso' ELSE 'Seco' END
      WHEN m.mesorregiao_id IN (2603, 2604, 2605) THEN
        CASE WHEN EXTRACT(MONTH FROM m.data) BETWEEN 4 AND 8 THEN 'Chuvoso' ELSE 'Seco' END
      ELSE 'Desconhecido'
    END AS periodo_clima,
    map.municipio_inferido,
    map.latitude,
    map.longitude,
    map.tipo_match
  FROM {{ source('bronze', 'monitoramento_pluviometrico') }} m
  LEFT JOIN mapeamento_final map
    ON m.codigo_posto = map.codigo_posto
),

dados_com_ilhas AS (
  SELECT
    *,
    SUM(CASE WHEN COALESCE(precipitacao, 0) > 0 THEN 1 ELSE 0 END)
      OVER (PARTITION BY codigo_posto ORDER BY data) as island_id
  FROM dados_base
)

SELECT
  codigo_posto,
  nome_posto,
  data,
  ano,
  mes,
  dia,
  dia_semana,
  precipitacao,
  mesorregiao_id,
  periodo_clima,
  municipio_inferido,
  latitude,
  longitude,
  tipo_match,
  CASE
    WHEN COALESCE(precipitacao, 0) < 20 THEN 'Normal'
    WHEN COALESCE(precipitacao, 0) >= 20 AND COALESCE(precipitacao, 0) < 50 THEN 'Perigo Potencial'
    WHEN COALESCE(precipitacao, 0) >= 50 AND COALESCE(precipitacao, 0) <= 100 THEN 'Perigo'
    ELSE 'Grande Perigo'
  END AS alerta_chuva,
  CASE
    WHEN COALESCE(precipitacao, 0) = 0 THEN
      ROW_NUMBER() OVER (PARTITION BY codigo_posto, island_id ORDER BY data)
    ELSE 0
  END AS dias_secos_consecutivos,
  AVG(precipitacao) OVER (PARTITION BY codigo_posto ORDER BY data ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS mm_7d
FROM dados_com_ilhas
