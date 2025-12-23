--Consulta 2 ¿Cuales son las startups y sus inversionistas sea persona, gobierno o organizacion
--(si es que lo hay) que se encuentran estancadas por mas de 6 meses en la etapa early stage?

WITH early_stuck AS (
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
