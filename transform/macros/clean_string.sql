{% macro clean_string(column_name) %}
  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
  REPLACE(REPLACE(REPLACE(REPLACE(
  REPLACE(REPLACE(REPLACE(
  REPLACE(REPLACE(REPLACE(REPLACE(
  REPLACE(REPLACE(REPLACE(REPLACE(
  REPLACE(REPLACE(REPLACE(
    UPPER(TRIM({{ column_name }})),
  'Á','A'), 'À','A'), 'Â','A'), 'Ã','A'), 'Ä','A'),
  'É','E'), 'È','E'), 'Ê','E'), 'Ë','E'),
  'Í','I'), 'Ì','I'), 'Î','I'), 'Ï','I'),
  'Ó','O'), 'Ò','O'), 'Ô','O'), 'Õ','O'), 'Ö','O'),
  'Ú','U'), 'Ù','U'), 'Û','U'), 'Ü','U'),
  'Ç','C')
{% endmacro %}
