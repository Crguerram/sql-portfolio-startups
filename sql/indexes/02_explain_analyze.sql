--CONSULTA 2
ANALYZE;
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) WITH  early_stuck AS (
  SELECT
    s.id_startup,
    s.nombre AS startup,
    e.id_early_stage,
    e.fecha AS early_fecha
  FROM early_stage e
  JOIN seed sd ON sd.id_seed = e.id_seed
  JOIN startup s ON s.id_startup = sd.id_startup
  LEFT JOIN growth_stage g ON g.id_early_stage = e.id_early_stage
  WHERE g.id_growth_stage IS NULL
    AND e.fecha <= (CURRENT_DATE - INTERVAL '6 months')
),
inv_persona AS (
  SELECT
    ci.id_early_stage,
    STRING_AGG(DISTINCT (p.nombre_completo || ' (DNI ' || p.dni || ')'), ', ') AS inversionistas_persona
  FROM contratoinversionista_early ci
  JOIN persona p ON p.dni = ci.dni
  GROUP BY ci.id_early_stage
),
inv_gob AS (
  SELECT
    cg.id_early_stage,
    STRING_AGG(DISTINCT (g.pais || ' (ID ' || g.id_gobierno || ')'), ', ') AS inversionistas_gobierno
  FROM contratogobierno_early cg
  JOIN gobierno g ON g.id_gobierno = cg.id_gobierno
  GROUP BY cg.id_early_stage
),
inv_org AS (
  SELECT
    co.id_early_stage,
    STRING_AGG(DISTINCT (o.nombre || ' (ID ' || o.id_organizacion || ')'), ', ') AS inversionistas_organizacion
  FROM contratoorganizacion_early co
  JOIN organizacion o ON o.id_organizacion = co.id_organizacion
  GROUP BY co.id_early_stage
)
SELECT
  es.startup,
  es.early_fecha,
  COALESCE(ip.inversionistas_persona, 'N/A') AS inversionista_persona,
  COALESCE(ig.inversionistas_gobierno, 'N/A') AS inversionista_gobierno,
  COALESCE(io.inversionistas_organizacion, 'N/A') AS inversionista_organizacion
FROM early_stuck es
LEFT JOIN inv_persona ip ON ip.id_early_stage = es.id_early_stage
LEFT JOIN inv_gob ig ON ig.id_early_stage = es.id_early_stage
LEFT JOIN inv_org io ON io.id_early_stage = es.id_early_stage
ORDER BY es.early_fecha ASC, es.startup;

--CONSULTA 7
EXPLAIN (ANALYZE,BUFFERS,VERBOSE) WITH inv_dates AS (
  SELECT fecha, monto FROM contratoinversionista_early
  UNION ALL SELECT fecha, monto FROM contratoinversionista_growth
  UNION ALL SELECT fecha, monto FROM contratoinversionista_expansion
  UNION ALL SELECT fecha, monto FROM contratogobierno_early
  UNION ALL SELECT fecha, monto FROM contratogobierno_growth
  UNION ALL SELECT fecha, monto FROM contratogobierno_expansion
  UNION ALL SELECT fecha, monto FROM contratoorganizacion_early
  UNION ALL SELECT fecha, monto FROM contratoorganizacion_growth
  UNION ALL SELECT fecha, monto FROM contratoorganizacion_expansion
),
by_month AS (
  SELECT
    DATE_TRUNC('month', fecha)::date AS mes,
    round(SUM(monto),2) AS inversion_mensual
  FROM inv_dates
  GROUP BY 1
)
SELECT
  mes,
  inversion_mensual,
  SUM(inversion_mensual) OVER (ORDER BY mes) AS inversion_acumulada
FROM by_month
ORDER BY mes;

--CONSULTA 8 

EXPLAIN (ANALYZE,BUFFERS,VERBOSE) WITH current_stage AS (
  SELECT
    s.id_startup,
    s.nombre AS startup,
    sd.fecha AS seed_fecha,
    e.fecha  AS early_fecha,
    g.fecha  AS growth_fecha,
    ex.fecha AS expansion_fecha,
    -- Detectar etapa actual: la más avanzada existente
    CASE
      WHEN ex.id_expansion_stage IS NOT NULL THEN 'Expansion'
      WHEN g.id_growth_stage IS NOT NULL THEN 'Growth'
      WHEN e.id_early_stage IS NOT NULL THEN 'Early'
      WHEN sd.id_seed IS NOT NULL THEN 'Seed'
      ELSE 'Pre_Seed'
    END AS etapa_actual,
    -- Fecha de inicio de la etapa actual
    CASE
      WHEN ex.id_expansion_stage IS NOT NULL THEN ex.fecha
      WHEN g.id_growth_stage IS NOT NULL THEN g.fecha
      WHEN e.id_early_stage IS NOT NULL THEN e.fecha
      WHEN sd.id_seed IS NOT NULL THEN sd.fecha
      ELSE NULL
    END AS fecha_inicio_etapa
  FROM startup s
  LEFT JOIN seed sd ON sd.id_startup = s.id_startup
  LEFT JOIN early_stage e ON e.id_seed = sd.id_seed
  LEFT JOIN growth_stage g ON g.id_early_stage = e.id_early_stage
  LEFT JOIN expansion_stage ex ON ex.id_growth_stage = g.id_growth_stage
),
stagnation AS (
  SELECT
    startup,
    etapa_actual,
    fecha_inicio_etapa,
    (CURRENT_DATE - fecha_inicio_etapa) AS dias_en_etapa
  FROM current_stage
  WHERE etapa_actual <> 'Pre_Seed'
    AND fecha_inicio_etapa IS NOT NULL
),
ranked AS (
  SELECT
    startup,
    etapa_actual,
    fecha_inicio_etapa,
    dias_en_etapa,
    ROW_NUMBER() OVER (PARTITION BY etapa_actual ORDER BY dias_en_etapa DESC) AS rank_en_etapa,
    PERCENT_RANK() OVER (PARTITION BY etapa_actual ORDER BY dias_en_etapa) AS percentil_en_etapa
  FROM stagnation
)
SELECT
  startup,
  etapa_actual,
  fecha_inicio_etapa,
  dias_en_etapa,
  rank_en_etapa,
  ROUND((100 * percentil_en_etapa)::numeric, 2) AS percentil_en_etapa
FROM ranked
ORDER BY dias_en_etapa DESC
LIMIT 50;
