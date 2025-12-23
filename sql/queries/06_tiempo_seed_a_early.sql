--consulta6
WITH base AS (
  SELECT
    s.id_incubadora,
    (e.fecha - sd.fecha) AS dias_seed_a_early
  FROM seed sd
  JOIN early_stage e ON e.id_seed = sd.id_seed
  JOIN startup s ON s.id_startup = sd.id_startup
)
SELECT
  i.nombre AS incubadora,
  COUNT(*) AS n_startups,
  ROUND(AVG(dias_seed_a_early)::numeric, 2) AS avg_dias,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY dias_seed_a_early) AS mediana_dias
FROM base b
JOIN incubadora i ON i.id_incubadora = b.id_incubadora
GROUP BY i.nombre
ORDER BY avg_dias DESC;
