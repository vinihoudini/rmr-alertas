{{
  config(
    materialized = 'table',
    schema = 'gold'
  )
}}

WITH latest_data AS (
    SELECT
        municipio_inferido,
        MAX(data) as max_data
    FROM {{ ref('monitoramento_pluviometrico') }}
    WHERE municipio_inferido IS NOT NULL
    GROUP BY 1
),
ranked_data AS (
    SELECT
        m.municipio_inferido as municipio,
        m.alerta_chuva,
        m.data as atualizacao,
        -- Pega o maior alerta/precipitacao em caso de multiplos postos no mesmo municipio na mesma data
        ROW_NUMBER() OVER(PARTITION BY m.municipio_inferido ORDER BY m.precipitacao DESC) as rn
    FROM {{ ref('monitoramento_pluviometrico') }} m
    INNER JOIN latest_data ld 
        ON m.municipio_inferido = ld.municipio_inferido 
        AND m.data = ld.max_data
)
SELECT
    ROW_NUMBER() OVER(ORDER BY municipio) as id,
    municipio,
    CASE alerta_chuva
        WHEN 'Normal' THEN 'Normal 🟢'
        WHEN 'Perigo Potencial' THEN 'Atenção 🟡'
        WHEN 'Perigo' THEN 'Alerta 🟠'
        WHEN 'Grande Perigo' THEN 'Perigo 🔴'
        ELSE 'Desconhecido ⚪'
    END as nivel_alerta,
    atualizacao
FROM ranked_data
WHERE rn = 1
