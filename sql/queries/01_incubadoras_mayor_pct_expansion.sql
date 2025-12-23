WITH total_por_incubadora AS (
  SELECT i.id_incubadora, i.nombre AS incubadora, COUNT(*) AS total_startups
  FROM incubadora i
  JOIN startup s ON s.id_incubadora = i.id_incubadora
  GROUP BY i.id_incubadora, i.nombre
),
exp_por_incubadora AS (
  SELECT i.id_incubadora, COUNT(DISTINCT s.id_startup) AS startups_expansion
  FROM incubadora i
  JOIN startup s ON s.id_incubadora = i.id_incubadora
  JOIN seed sd ON sd.id_startup = s.id_startup
  JOIN early_stage e ON e.id_seed = sd.id_seed
  JOIN growth_stage g ON g.id_early_stage = e.id_early_stage
  JOIN expansion_stage ex ON ex.id_growth_stage = g.id_growth_stage
  GROUP BY i.id_incubadora
)
SELECT
  t.incubadora,
  t.total_startups,
  COALESCE(e.startups_expansion, 0) AS startups_expansion,
  ROUND(100.0 * COALESCE(e.startups_expansion,0) / NULLIF(t.total_startups,0), 2) AS pct_expansion
FROM total_por_incubadora t
LEFT JOIN exp_por_incubadora e ON e.id_incubadora = t.id_incubadora
ORDER BY pct_expansion DESC, startups_expansion DESC, total_startups DESC
LIMIT 3;
