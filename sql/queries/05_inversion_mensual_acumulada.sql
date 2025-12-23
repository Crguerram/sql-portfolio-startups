--Top 3 startups por incubadora según monto total invertido (todas las etapas)
WITH inv AS (
  SELECT sd.id_startup, ci.monto
  FROM contratoinversionista_early ci
  JOIN early_stage e ON e.id_early_stage = ci.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed
  UNION ALL
  SELECT sd.id_startup, cg.monto
  FROM contratogobierno_early cg
  JOIN early_stage e ON e.id_early_stage = cg.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed
  UNION ALL
  SELECT sd.id_startup, co.monto
  FROM contratoorganizacion_early co
  JOIN early_stage e ON e.id_early_stage = co.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed

  UNION ALL
  SELECT sd.id_startup, ci.monto
  FROM contratoinversionista_growth ci
  JOIN growth_stage g ON g.id_growth_stage = ci.id_growth_stage
  JOIN early_stage e ON e.id_early_stage = g.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed
  UNION ALL
  SELECT sd.id_startup, cg.monto
  FROM contratogobierno_growth cg
  JOIN growth_stage g ON g.id_growth_stage = cg.id_growth_stage
  JOIN early_stage e ON e.id_early_stage = g.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed
  UNION ALL
  SELECT sd.id_startup, co.monto
  FROM contratoorganizacion_growth co
  JOIN growth_stage g ON g.id_growth_stage = co.id_growth_stage
  JOIN early_stage e ON e.id_early_stage = g.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed

  UNION ALL
  SELECT sd.id_startup, ci.monto
  FROM contratoinversionista_expansion ci
  JOIN expansion_stage ex ON ex.id_expansion_stage = ci.id_expansion_stage
  JOIN growth_stage g ON g.id_growth_stage = ex.id_growth_stage
  JOIN early_stage e ON e.id_early_stage = g.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed
  UNION ALL
  SELECT sd.id_startup, cg.monto
  FROM contratogobierno_expansion cg
  JOIN expansion_stage ex ON ex.id_expansion_stage = cg.id_expansion_stage
  JOIN growth_stage g ON g.id_growth_stage = ex.id_growth_stage
  JOIN early_stage e ON e.id_early_stage = g.id_early_stage
  JOIN seed sd ON sd.id_seed = e.id_seed
  UNION ALL
  SELECT sd.id_startup, co.monto
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
ranked AS (
  SELECT
    i.nombre AS incubadora,
    s.nombre AS startup,
    t.monto_total,
    ROW_NUMBER() OVER (PARTITION BY s.id_incubadora ORDER BY t.monto_total DESC) AS rn
  FROM tot t
  JOIN startup s ON s.id_startup = t.id_startup
  JOIN incubadora i ON i.id_incubadora = s.id_incubadora
)
SELECT incubadora, startup, round(monto_total,2)
FROM ranked
WHERE rn <= 3
ORDER BY incubadora, monto_total DESC;
