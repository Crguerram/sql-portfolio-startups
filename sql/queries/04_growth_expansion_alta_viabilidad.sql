--Consulta 4 ¿Que startups en etapas avanzadas (Growth o Expansion) con alta viabilidad
--han recibido inversion de otros actores?

WITH advanced AS (
  SELECT
    s.id_startup,
    s.nombre AS startup,
    sd.viabilidad,
    CASE
      WHEN ex.id_expansion_stage IS NOT NULL THEN 'Expansion'
      WHEN g.id_growth_stage IS NOT NULL THEN 'Growth'
    END AS etapa_avanzada,
    g.id_growth_stage,
    ex.id_expansion_stage
  FROM startup s
  JOIN seed sd ON sd.id_startup = s.id_startup
  LEFT JOIN early_stage e ON e.id_seed = sd.id_seed
  LEFT JOIN growth_stage g ON g.id_early_stage = e.id_early_stage
  LEFT JOIN expansion_stage ex ON ex.id_growth_stage = g.id_growth_stage
  WHERE sd.viabilidad = 'Alta'
    AND (g.id_growth_stage IS NOT NULL OR ex.id_expansion_stage IS NOT NULL)
),
otros_actores AS (
  SELECT a.id_startup, 'Gobierno' AS actor, 'Growth' AS etapa, SUM(cg.monto) AS monto
  FROM advanced a
  JOIN contratogobierno_growth cg ON cg.id_growth_stage = a.id_growth_stage
  GROUP BY a.id_startup
  UNION ALL
  SELECT a.id_startup, 'Organización', 'Growth', SUM(co.monto)
  FROM advanced a
  JOIN contratoorganizacion_growth co ON co.id_growth_stage = a.id_growth_stage
  GROUP BY a.id_startup
  UNION ALL
  SELECT a.id_startup, 'Gobierno', 'Expansion', SUM(cg.monto)
  FROM advanced a
  JOIN contratogobierno_expansion cg ON cg.id_expansion_stage = a.id_expansion_stage
  GROUP BY a.id_startup
  UNION ALL
  SELECT a.id_startup, 'Organización', 'Expansion', SUM(co.monto)
  FROM advanced a
  JOIN contratoorganizacion_expansion co ON co.id_expansion_stage = a.id_expansion_stage
  GROUP BY a.id_startup
)
SELECT
  a.startup,
  a.etapa_avanzada,
  a.viabilidad,
  STRING_AGG(oa.actor || ' en ' || oa.etapa || ' (monto=' || ROUND(oa.monto::numeric,2) || ')', ' | ') AS inversion_otros_actores
FROM advanced a
JOIN otros_actores oa ON oa.id_startup = a.id_startup
GROUP BY a.startup, a.etapa_avanzada, a.viabilidad
ORDER BY a.etapa_avanzada DESC, a.startup;
