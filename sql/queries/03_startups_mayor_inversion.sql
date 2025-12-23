--Consulta 3 ¿Que startups han recibido el mayor monto total de inversion y en que etapas?

WITH inv AS (
  -- EARLY (persona/gob/org)
  SELECT sd.id_startup, 'Early' AS etapa, ci.monto
  FROM contratoinversionista_early ci
  JOIN early_stage e ON e.id_early_stage = ci.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed
  UNION ALL
  SELECT sd.id_startup, 'Early', cg.monto
  FROM contratogobierno_early cg
  JOIN early_stage e ON e.id_early_stage = cg.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed
  UNION ALL
  SELECT sd.id_startup, 'Early', co.monto
  FROM contratoorganizacion_early co
  JOIN early_stage e ON e.id_early_stage = co.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed

  -- GROWTH
  UNION ALL
  SELECT sd.id_startup, 'Growth', ci.monto
  FROM contratoinversionista_growth ci
  JOIN growth_stage g ON g.id_growth_stage = ci.id_growth_stage
  JOIN early_stage e ON e.id_early_stage = g.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed
  UNION ALL
  SELECT sd.id_startup, 'Growth', cg.monto
  FROM contratogobierno_growth cg
  JOIN growth_stage g ON g.id_growth_stage = cg.id_growth_stage
  JOIN early_stage e ON e.id_early_stage = g.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed
  UNION ALL
  SELECT sd.id_startup, 'Growth', co.monto
  FROM contratoorganizacion_growth co
  JOIN growth_stage g ON g.id_growth_stage = co.id_growth_stage
  JOIN early_stage e ON e.id_early_stage = g.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed

  -- EXPANSION
  UNION ALL
  SELECT sd.id_startup, 'Expansion', ci.monto
  FROM contratoinversionista_expansion ci
  JOIN expansion_stage ex ON ex.id_expansion_stage = ci.id_expansion_stage
  JOIN growth_stage g ON g.id_growth_stage = ex.id_growth_stage
  JOIN early_stage e ON e.id_early_stage = g.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed
  UNION ALL
  SELECT sd.id_startup, 'Expansion', cg.monto
  FROM contratogobierno_expansion cg
  JOIN expansion_stage ex ON ex.id_expansion_stage = cg.id_expansion_stage
  JOIN growth_stage g ON g.id_growth_stage = ex.id_growth_stage
  JOIN early_stage e ON e.id_early_stage = g.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed
  UNION ALL
  SELECT sd.id_startup, 'Expansion', co.monto
  FROM contratoorganizacion_expansion co
  JOIN expansion_stage ex ON ex.id_expansion_stage = co.id_expansion_stage
  JOIN growth_stage g ON g.id_growth_stage = ex.id_growth_stage
  JOIN early_stage e ON e.id_early_stage = g.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed
),
tot AS (
  SELECT id_startup, SUM(monto) AS monto_total
  FROM inv
  GROUP BY id_startup
),
top10 AS (
  SELECT id_startup, monto_total
  FROM tot
  ORDER BY monto_total DESC
  LIMIT 10
),
by_stage AS (
  SELECT id_startup, etapa, SUM(monto) AS monto_etapa
  FROM inv
  GROUP BY id_startup, etapa
)
SELECT
  s.nombre AS startup,
  t.monto_total,
  STRING_AGG(bs.etapa || ': ' || ROUND(bs.monto_etapa::numeric,2), ' | ' ORDER BY bs.monto_etapa DESC) AS detalle_por_etapa
FROM top10 t
JOIN startup s ON s.id_startup = t.id_startup
JOIN by_stage bs ON bs.id_startup = t.id_startup
GROUP BY s.nombre, t.monto_total
ORDER BY t.monto_total DESC;
