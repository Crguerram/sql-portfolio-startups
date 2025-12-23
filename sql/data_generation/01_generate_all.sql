
-- 01_generate_all.sql
-- Generación sintética paramétrica (1k / 10k / 100k)

-- 0) Datos base (catálogos)

-- ODS (1..17)
INSERT INTO ods (id_ods)
SELECT gs
FROM generate_series(1,17) gs
ON CONFLICT DO NOTHING;

-- Gobiernos (países ejemplo)
INSERT INTO gobierno (id_gobierno, pais)
SELECT gs, pais
FROM (
  SELECT ROW_NUMBER() OVER() AS gs, pais
  FROM (VALUES
    ('Perú'),('Chile'),('Colombia'),('México'),('Argentina'),
    ('Brasil'),('Ecuador'),('Bolivia'),('Uruguay'),('España')
  ) v(pais)
) x
ON CONFLICT DO NOTHING;

-- Incubadoras
INSERT INTO incubadora (id_incubadora, nombre)
SELECT gs, nombre
FROM (
  SELECT ROW_NUMBER() OVER() AS gs, nombre
  FROM (VALUES
    ('UTEC Ventures'),('SeedLab'),('Wayra'),('Startup Perú'),
    ('InnovateX'),('AndesHub'),('ImpactLab'),('Pacific Accelerator')
  ) v(nombre)
) x
ON CONFLICT DO NOTHING;

-- Organizaciones
INSERT INTO organizacion (id_organizacion, nombre, objetivo)
SELECT gs, nombre, objetivo
FROM (
  SELECT ROW_NUMBER() OVER() AS gs, nombre, objetivo
  FROM (VALUES
    ('ONG Salud Abierta','Mejorar acceso a salud'),
    ('Fundación Educa Perú','Reducir brecha educativa'),
    ('Agua Segura','Acceso a agua potable'),
    ('Energía Limpia','Transición energética'),
    ('Ciudad Sostenible','Movilidad y urbanismo sostenible')
  ) v(nombre, objetivo)
) x
ON CONFLICT DO NOTHING;



-- 1) Generación paramétrica
--    Cambiar N_STARTUPS: 1000 | 10000 | 100000

DO $$
DECLARE
  N_STARTUPS INT := 1000;           -- CAMBIAR AQUÍ PARA DISTINTOS TAMANIOS DE DATA
  PERSONAS_X_STARTUP INT := 5;      -- 1 fundador + 4 participantes
BEGIN

  -- A) STARTUPS + PRE_SEED
  INSERT INTO startup (id_startup, id_incubadora, nombre, sector)
  SELECT
    s.id_startup,
    1 + (random()*7)::int,
    'Startup_' || s.id_startup,
    (ARRAY['Fintech','Edtech','Healthtech','Agrotech','Cleantech','Govtech','Retailtech'])[1+(random()*6)::int]
  FROM generate_series(1, N_STARTUPS) s(id_startup)
  ON CONFLICT DO NOTHING;

  INSERT INTO pre_seed (id_pre_seed, id_startup, mvp)
  SELECT
    st.id_startup,
    st.id_startup,
    'MVP para ' || st.nombre || ' enfocado en ' || st.sector
  FROM startup st
  WHERE st.id_startup BETWEEN 1 AND N_STARTUPS
  ON CONFLICT DO NOTHING;

  -- B) PERSONAS + ROLES
  INSERT INTO persona (dni, edad, profesion, nombre_completo)
  SELECT
    (10000000 + gs),
    18 + (random()*42)::int,
    (ARRAY['Ingeniero','Economista','Diseñador','Médico','Administrador','Abogado','Analista de Datos'])[1+(random()*6)::int],
    'Persona_' || gs
  FROM generate_series(1, N_STARTUPS*PERSONAS_X_STARTUP) gs
  ON CONFLICT DO NOTHING;

  INSERT INTO fundador (dni, rol)
  SELECT
    (10000000 + gs),
    (ARRAY['CEO','CTO','COO','CPO'])[1+(random()*3)::int]
  FROM generate_series(1, N_STARTUPS) gs
  ON CONFLICT DO NOTHING;

  INSERT INTO participante (dni, funcion)
  SELECT
    (10000000 + gs),
    (ARRAY['Desarrollo','Marketing','Ventas','Operaciones','Data','UX'])[1+(random()*5)::int]
  FROM generate_series(N_STARTUPS+1, N_STARTUPS*PERSONAS_X_STARTUP) gs
  ON CONFLICT DO NOTHING;

  INSERT INTO inversionista (dni, capital)
  SELECT
    p.dni,
    (5000 + random()*200000)::int
  FROM persona p
  WHERE random() < 0.20
  ON CONFLICT DO NOTHING;

  -- C) FUNDO (1 por startup)
  INSERT INTO fundo (id_startup, dni, fecha)
  SELECT
    st.id_startup,
    (10000000 + st.id_startup),
    (CURRENT_DATE - (730 + (random()*1460)::int))::date
  FROM startup st
  WHERE st.id_startup BETWEEN 1 AND N_STARTUPS
  ON CONFLICT DO NOTHING;

  -- D) PARTICIPA (4 por startup)
  INSERT INTO participa (id_startup, dni, fecha_union)
  SELECT
    st.id_startup,
    (10000000 + (N_STARTUPS + ((st.id_startup-1)*4 + k))),
    (f.fecha + (30 + (random()*365)::int))::date
  FROM startup st
  JOIN fundo f ON f.id_startup = st.id_startup
  CROSS JOIN generate_series(1,4) k
  WHERE st.id_startup BETWEEN 1 AND N_STARTUPS
  ON CONFLICT DO NOTHING;

  -- E) IMPACTA (3 ODS por startup)
  INSERT INTO impacta (id_startup, id_ods)
  SELECT
    st.id_startup,
    1 + (random()*16)::int
  FROM startup st
  CROSS JOIN generate_series(1, 3) rep
  WHERE st.id_startup BETWEEN 1 AND N_STARTUPS
  ON CONFLICT DO NOTHING;

  -- F) ETAPAS con calendario consistente (evita errores de triggers)
  WITH cal AS (
    SELECT
      st.id_startup,
      f.fecha AS fundo_fecha,
      (f.fecha + ( 30 + (random()*150)::int))::date  AS seed_fecha,
      (f.fecha + (200 + (random()*300)::int))::date  AS early_fecha,
      (f.fecha + (450 + (random()*400)::int))::date  AS growth_fecha,
      (f.fecha + (800 + (random()*450)::int))::date  AS expansion_fecha,
      (f.fecha + (1200 + (random()*450)::int))::date AS exit_fecha,
      (random() < 0.70) AS pasa_seed,
      (random() < 0.40) AS pasa_early,
      (random() < 0.20) AS pasa_growth,
      (random() < 0.10) AS pasa_expansion,
      (random() < 0.05) AS pasa_exit
    FROM startup st
    JOIN fundo f ON f.id_startup = st.id_startup
    WHERE st.id_startup BETWEEN 1 AND N_STARTUPS
  ),
  ins_seed AS (
    INSERT INTO seed (id_seed, id_pre_seed, id_startup, viabilidad, fecha)
    SELECT
      c.id_startup,
      c.id_startup,
      c.id_startup,
      (CASE
        WHEN random() < 0.30 THEN 'Alta'
        WHEN random() < 0.80 THEN 'Media'
        ELSE 'Baja'
      END),
      LEAST(GREATEST(c.seed_fecha, c.fundo_fecha + 1), CURRENT_DATE)::date
    FROM cal c
    WHERE c.pasa_seed
    ON CONFLICT DO NOTHING
    RETURNING id_seed, id_startup, fecha
  ),
  ins_early AS (
    INSERT INTO early_stage (id_early_stage, id_seed, fecha)
    SELECT
      s.id_seed,
      s.id_seed,
      LEAST(GREATEST(c.early_fecha, s.fecha + 1), CURRENT_DATE)::date
    FROM ins_seed s
    JOIN cal c ON c.id_startup = s.id_startup
    WHERE c.pasa_early
    ON CONFLICT DO NOTHING
    RETURNING id_early_stage, fecha
  ),
  ins_growth AS (
    INSERT INTO growth_stage (id_growth_stage, flujo_de_caja, id_early_stage, fecha)
    SELECT
      e.id_early_stage,
      (5000 + random()*200000)::decimal,
      e.id_early_stage,
      LEAST(GREATEST(c.growth_fecha, e.fecha + 1), CURRENT_DATE)::date
    FROM ins_early e
    JOIN seed sd ON sd.id_seed = e.id_early_stage
    JOIN cal c ON c.id_startup = sd.id_startup
    WHERE c.pasa_growth
    ON CONFLICT DO NOTHING
    RETURNING id_growth_stage, fecha
  ),
  ins_exp AS (
    INSERT INTO expansion_stage (id_expansion_stage, id_growth_stage, fecha)
    SELECT
      g.id_growth_stage,
      g.id_growth_stage,
      LEAST(GREATEST(c.expansion_fecha, g.fecha + 1), CURRENT_DATE)::date
    FROM ins_growth g
    JOIN growth_stage gg ON gg.id_growth_stage = g.id_growth_stage
    JOIN early_stage ee ON ee.id_early_stage = gg.id_early_stage
    JOIN seed sd ON sd.id_seed = ee.id_seed
    JOIN cal c ON c.id_startup = sd.id_startup
    WHERE c.pasa_expansion
    ON CONFLICT DO NOTHING
    RETURNING id_expansion_stage, fecha
  )
  INSERT INTO exit (id_exit, id_expansion_stage, fecha)
  SELECT
    ex.id_expansion_stage,
    ex.id_expansion_stage,
    LEAST(GREATEST(c.exit_fecha, ex.fecha + 1), CURRENT_DATE)::date
  FROM ins_exp ex
  JOIN expansion_stage ex2 ON ex2.id_expansion_stage = ex.id_expansion_stage
  JOIN growth_stage g2 ON g2.id_growth_stage = ex2.id_growth_stage
  JOIN early_stage e2 ON e2.id_early_stage = g2.id_early_stage
  JOIN seed s2 ON s2.id_seed = e2.id_seed
  JOIN cal c ON c.id_startup = s2.id_startup
  WHERE c.pasa_exit
  ON CONFLICT DO NOTHING;

  -- G) CONTRATOS (probabilísticos)
  INSERT INTO contratogobierno_early (id_gobierno, id_early_stage, fecha, monto)
  SELECT 1 + (random()*9)::int, e.id_early_stage, (e.fecha - (1 + (random()*60)::int))::date, (1000 + random()*50000)::decimal
  FROM early_stage e
  WHERE random() < 0.35
  ON CONFLICT DO NOTHING;

  INSERT INTO contratogobierno_growth (id_gobierno, id_growth_stage, fecha, monto)
  SELECT 1 + (random()*9)::int, g.id_growth_stage, (g.fecha - (1 + (random()*60)::int))::date, (5000 + random()*150000)::decimal
  FROM growth_stage g
  WHERE random() < 0.40
  ON CONFLICT DO NOTHING;

  INSERT INTO contratogobierno_expansion (id_gobierno, id_expansion_stage, fecha, monto)
  SELECT 1 + (random()*9)::int, ex.id_expansion_stage, (ex.fecha - (1 + (random()*60)::int))::date, (10000 + random()*250000)::decimal
  FROM expansion_stage ex
  WHERE random() < 0.50
  ON CONFLICT DO NOTHING;

  INSERT INTO contratoorganizacion_early (id_organizacion, id_early_stage, fecha, monto)
  SELECT 1 + (random()*4)::int, e.id_early_stage, (e.fecha - (1 + (random()*60)::int))::date, (500 + random()*20000)::decimal
  FROM early_stage e
  WHERE random() < 0.30
  ON CONFLICT DO NOTHING;

  INSERT INTO contratoorganizacion_growth (id_organizacion, id_growth_stage, fecha, monto)
  SELECT 1 + (random()*4)::int, g.id_growth_stage, (g.fecha - (1 + (random()*60)::int))::date, (2000 + random()*70000)::decimal
  FROM growth_stage g
  WHERE random() < 0.35
  ON CONFLICT DO NOTHING;

  INSERT INTO contratoorganizacion_expansion (id_organizacion, id_expansion_stage, fecha, monto)
  SELECT 1 + (random()*4)::int, ex.id_expansion_stage, (ex.fecha - (1 + (random()*60)::int))::date, (5000 + random()*120000)::decimal
  FROM expansion_stage ex
  WHERE random() < 0.40
  ON CONFLICT DO NOTHING;

  INSERT INTO contratoinversionista_early (dni, id_early_stage, fecha, monto)
  SELECT inv.dni, e.id_early_stage, (e.fecha - (1 + (random()*60)::int))::date, (1000 + random()*80000)::decimal
  FROM early_stage e
  JOIN LATERAL (SELECT dni FROM inversionista ORDER BY random() LIMIT 1) inv ON true
  WHERE random() < 0.50
  ON CONFLICT DO NOTHING;

  INSERT INTO contratoinversionista_growth (dni, id_growth_stage, fecha, monto)
  SELECT inv.dni, g.id_growth_stage, (g.fecha - (1 + (random()*60)::int))::date, (5000 + random()*200000)::decimal
  FROM growth_stage g
  JOIN LATERAL (SELECT dni FROM inversionista ORDER BY random() LIMIT 1) inv ON true
  WHERE random() < 0.60
  ON CONFLICT DO NOTHING;

  INSERT INTO contratoinversionista_expansion (dni, id_expansion_stage, fecha, monto)
  SELECT inv.dni, ex.id_expansion_stage, (ex.fecha - (1 + (random()*60)::int))::date, (10000 + random()*350000)::decimal
  FROM expansion_stage ex
  JOIN LATERAL (SELECT dni FROM inversionista ORDER BY random() LIMIT 1) inv ON true
  WHERE random() < 0.70
  ON CONFLICT DO NOTHING;

END $$;



