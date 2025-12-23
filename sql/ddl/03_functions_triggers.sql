-- Fundo -> Seed
CREATE OR REPLACE FUNCTION validarFechaDeFundoSeed()
RETURNS TRIGGER AS $$
DECLARE
  fechaFundo DATE;
BEGIN
  SELECT min(f.fecha)
    INTO fechaFundo
  FROM fundo f
  WHERE f.id_startup = NEW.id_startup;

  IF fechaFundo IS NULL THEN
    RAISE EXCEPTION 'No existe registro en FUNDO para la startup %', NEW.id_startup;
  END IF;

  IF NEW.fecha <= fechaFundo THEN
    RAISE EXCEPTION 'La fecha en Seed debe ser mayor que la fecha de Fundo (startup %)', NEW.id_startup;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validarFechaDeFundoSeed ON seed;

CREATE TRIGGER trigger_validarFechaDeFundoSeed
BEFORE INSERT OR UPDATE ON seed
FOR EACH ROW
EXECUTE FUNCTION validarFechaDeFundoSeed();


-- Seed -> EarlyStage (early_stage tiene id_seed)
CREATE OR REPLACE FUNCTION validarFechaDeSeedEarlyStage()
RETURNS TRIGGER AS $$
DECLARE
  fechaSeed DATE;
BEGIN
  SELECT s.fecha
    INTO fechaSeed
  FROM seed s
  WHERE s.id_seed = NEW.id_seed;

  IF fechaSeed IS NULL THEN
    RAISE EXCEPTION 'No existe registro SEED con id_seed %', NEW.id_seed;
  END IF;

  IF NEW.fecha <= fechaSeed THEN
    RAISE EXCEPTION 'La fecha en Early Stage debe ser mayor que la fecha de Seed (id_seed %)', NEW.id_seed;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validarFechaDeSeedEarlyStage ON early_stage;

CREATE TRIGGER trigger_validarFechaDeSeedEarlyStage
BEFORE INSERT OR UPDATE ON early_stage
FOR EACH ROW
EXECUTE FUNCTION validarFechaDeSeedEarlyStage();


-- EarlyStage -> GrowthStage (growth_stage tiene id_early_stage)
CREATE OR REPLACE FUNCTION validarEarlyStageGrowth()
RETURNS TRIGGER AS $$
DECLARE
  fechaEarly DATE;
BEGIN
  SELECT e.fecha
    INTO fechaEarly
  FROM early_stage e
  WHERE e.id_early_stage = NEW.id_early_stage;

  IF fechaEarly IS NULL THEN
    RAISE EXCEPTION 'No existe registro EARLY_STAGE con id_early_stage %', NEW.id_early_stage;
  END IF;

  IF NEW.fecha <= fechaEarly THEN
    RAISE EXCEPTION 'La fecha en Growth Stage debe ser mayor que la fecha de Early Stage (id_early_stage %)',
      NEW.id_early_stage;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validarEarlyStageGrowth ON growth_stage;

CREATE TRIGGER trigger_validarEarlyStageGrowth
BEFORE INSERT OR UPDATE ON growth_stage
FOR EACH ROW
EXECUTE FUNCTION validarEarlyStageGrowth();


-- GrowthStage -> ExpansionStage (expansion_stage tiene id_growth_stage)
CREATE OR REPLACE FUNCTION validarGrowthExpansionStage()
RETURNS TRIGGER AS $$
DECLARE
  fechaGrowth DATE;
BEGIN
  SELECT g.fecha
    INTO fechaGrowth
  FROM growth_stage g
  WHERE g.id_growth_stage = NEW.id_growth_stage;

  IF fechaGrowth IS NULL THEN
    RAISE EXCEPTION 'No existe registro GROWTH_STAGE con id_growth_stage %', NEW.id_growth_stage;
  END IF;

  IF NEW.fecha <= fechaGrowth THEN
    RAISE EXCEPTION 'La fecha en Expansion Stage debe ser mayor que la fecha de Growth (id_growth_stage %)',
      NEW.id_growth_stage;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validarGrowthExpansionStage ON expansion_stage;

CREATE TRIGGER trigger_validarGrowthExpansionStage
BEFORE INSERT OR UPDATE ON expansion_stage
FOR EACH ROW
EXECUTE FUNCTION validarGrowthExpansionStage();


-- ExpansionStage -> Exit (exit tiene id_expansion_stage)
CREATE OR REPLACE FUNCTION validarExpansionStageExit()
RETURNS TRIGGER AS $$
DECLARE
  fechaExpansion DATE;
BEGIN
  SELECT ex.fecha
    INTO fechaExpansion
  FROM expansion_stage ex
  WHERE ex.id_expansion_stage = NEW.id_expansion_stage;

  IF fechaExpansion IS NULL THEN
    RAISE EXCEPTION 'No existe registro EXPANSION_STAGE con id_expansion_stage %', NEW.id_expansion_stage;
  END IF;

  IF NEW.fecha <= fechaExpansion THEN
    RAISE EXCEPTION 'La fecha en Exit debe ser mayor que la fecha de Expansion Stage (id_expansion_stage %)',
      NEW.id_expansion_stage;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validarExpansionStageExit ON exit;

CREATE TRIGGER trigger_validarExpansionStageExit
BEFORE INSERT OR UPDATE ON exit
FOR EACH ROW
EXECUTE FUNCTION validarExpansionStageExit();


-- Viabilidad: Solo Alta/Media/Baja
CREATE OR REPLACE FUNCTION validarViabilidadSeed()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.viabilidad NOT IN ('Alta', 'Media', 'Baja') THEN
    RAISE EXCEPTION 'Valor inválido para viabilidad: solo se permite Alta, Media o Baja.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validarViabilidadSeed ON seed;

CREATE TRIGGER trigger_validarViabilidadSeed
BEFORE INSERT OR UPDATE ON seed
FOR EACH ROW
EXECUTE FUNCTION validarViabilidadSeed();



-- FUNCIONES: PASAR DE ETAPA

-- Pre-seed -> Seed
CREATE OR REPLACE FUNCTION Preseed_A_Seed(id_preseed BIGINT, viability VARCHAR(50))
RETURNS VOID AS $$
DECLARE
  id_startup_result BIGINT;
  nuevo_id_seed BIGINT;
BEGIN
  -- Validar viabilidad
  IF viability NOT IN ('Alta','Media','Baja') THEN
    RAISE EXCEPTION 'Valor inválido para viabilidad: solo Alta, Media o Baja.';
  END IF;

  -- Verificar que exista pre_seed y obtener startup
  SELECT p.id_startup
    INTO id_startup_result
  FROM pre_seed p
  WHERE p.id_pre_seed = id_preseed;

  IF id_startup_result IS NULL THEN
    RAISE EXCEPTION 'No existe registro PRE_SEED con id_pre_seed %', id_preseed;
  END IF;

  -- Evitar duplicidad: una startup no debería tener 2 seeds
  IF EXISTS (SELECT 1 FROM seed s WHERE s.id_startup = id_startup_result) THEN
    RAISE EXCEPTION 'La startup % ya tiene un registro en SEED', id_startup_result;
  END IF;

  -- Generar nuevo id (tu enfoque actual)
  SELECT COALESCE(MAX(id_seed), 0) + 1
    INTO nuevo_id_seed
  FROM seed;

  INSERT INTO seed (id_seed, id_pre_seed, id_startup, viabilidad, fecha)
  VALUES (nuevo_id_seed, id_preseed, id_startup_result, viability, CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;


-- Seed -> Early Stage
CREATE OR REPLACE FUNCTION Seed_A_EarlyStage(bid_seed BIGINT)
RETURNS VOID AS $$
DECLARE
  nuevo_id_earlystage BIGINT;
  fechaSeed DATE;
BEGIN
  -- Verificar existencia de seed
  SELECT s.fecha
    INTO fechaSeed
  FROM seed s
  WHERE s.id_seed = bid_seed;

  IF fechaSeed IS NULL THEN
    RAISE EXCEPTION 'No existe registro SEED con id_seed %', bid_seed;
  END IF;

  -- Evitar duplicidad: un seed no debería tener 2 early_stage
  IF EXISTS (SELECT 1 FROM early_stage e WHERE e.id_seed = bid_seed) THEN
    RAISE EXCEPTION 'El SEED % ya tiene un registro en EARLY_STAGE', bid_seed;
  END IF;

  SELECT COALESCE(MAX(id_early_stage), 0) + 1
    INTO nuevo_id_earlystage
  FROM early_stage;

  INSERT INTO early_stage (id_early_stage, id_seed, fecha)
  VALUES (nuevo_id_earlystage, bid_seed, CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;


-- Early Stage -> Growth Stage
CREATE OR REPLACE FUNCTION EarlyStage_A_GrowthStage(bid_EarlyStage BIGINT, flujoCaja DECIMAL)
RETURNS VOID AS $$
DECLARE
  nuevo_id_GrowthStage BIGINT;
  fechaEarly DATE;
BEGIN
  -- Verificar existencia de early_stage
  SELECT e.fecha
    INTO fechaEarly
  FROM early_stage e
  WHERE e.id_early_stage = bid_EarlyStage;

  IF fechaEarly IS NULL THEN
    RAISE EXCEPTION 'No existe registro EARLY_STAGE con id_early_stage %', bid_EarlyStage;
  END IF;

  -- Evitar duplicidad
  IF EXISTS (SELECT 1 FROM growth_stage g WHERE g.id_early_stage = bid_EarlyStage) THEN
    RAISE EXCEPTION 'El EARLY_STAGE % ya tiene un registro en GROWTH_STAGE', bid_EarlyStage;
  END IF;

  SELECT COALESCE(MAX(id_growth_stage), 0) + 1
    INTO nuevo_id_GrowthStage
  FROM growth_stage;

  INSERT INTO growth_stage (id_growth_stage, flujo_de_caja, id_early_stage, fecha)
  VALUES (nuevo_id_GrowthStage, flujoCaja, bid_EarlyStage, CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;


-- Growth Stage -> Expansion Stage
CREATE OR REPLACE FUNCTION GrowthStage_A_ExpansionStage(bid_GrowthStage BIGINT)
RETURNS VOID AS $$
DECLARE
  nuevo_id_ExpansionStage BIGINT;
  fechaGrowth DATE;
BEGIN
  -- Verificar existencia de growth_stage
  SELECT g.fecha
    INTO fechaGrowth
  FROM growth_stage g
  WHERE g.id_growth_stage = bid_GrowthStage;

  IF fechaGrowth IS NULL THEN
    RAISE EXCEPTION 'No existe registro GROWTH_STAGE con id_growth_stage %', bid_GrowthStage;
  END IF;

  -- Evitar duplicidad
  IF EXISTS (SELECT 1 FROM expansion_stage ex WHERE ex.id_growth_stage = bid_GrowthStage) THEN
    RAISE EXCEPTION 'El GROWTH_STAGE % ya tiene un registro en EXPANSION_STAGE', bid_GrowthStage;
  END IF;

  SELECT COALESCE(MAX(id_expansion_stage), 0) + 1
    INTO nuevo_id_ExpansionStage
  FROM expansion_stage;

  INSERT INTO expansion_stage (id_expansion_stage, id_growth_stage, fecha)
  VALUES (nuevo_id_ExpansionStage, bid_GrowthStage, CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;


-- Expansion Stage -> Exit
CREATE OR REPLACE FUNCTION ExpansionStage_A_Exit(bid_ExpansionStage BIGINT)
RETURNS VOID AS $$
DECLARE
  nuevo_id_Exit BIGINT;
  fechaExpansion DATE;
BEGIN
  -- Verificar existencia de expansion_stage
  SELECT ex.fecha
    INTO fechaExpansion
  FROM expansion_stage ex
  WHERE ex.id_expansion_stage = bid_ExpansionStage;

  IF fechaExpansion IS NULL THEN
    RAISE EXCEPTION 'No existe registro EXPANSION_STAGE con id_expansion_stage %', bid_ExpansionStage;
  END IF;

  -- Evitar duplicidad
  IF EXISTS (SELECT 1 FROM exit e WHERE e.id_expansion_stage = bid_ExpansionStage) THEN
    RAISE EXCEPTION 'El EXPANSION_STAGE % ya tiene un registro en EXIT', bid_ExpansionStage;
  END IF;

  SELECT COALESCE(MAX(id_exit), 0) + 1
    INTO nuevo_id_Exit
  FROM exit;

  INSERT INTO exit (id_exit, id_expansion_stage, fecha)
  VALUES (nuevo_id_Exit, bid_ExpansionStage, CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;
