--consulta8: Ranking de estancamiento en etapas (Lead time + percentil por etapa)

WITH current_stage AS (
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
  FROM public.startup s
  LEFT JOIN public.seed sd ON sd.id_startup = s.id_startup
  LEFT JOIN public.early_stage e ON e.id_seed = sd.id_seed
  LEFT JOIN public.growth_stage g ON g.id_early_stage = e.id_early_stage
  LEFT JOIN public.expansion_stage ex ON ex.id_growth_stage = g.id_growth_stage
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
