
-- 02_constraints.sql
-- Constraints y reglas de integridad


-- 1) Agregar columnas de fecha a etapas
ALTER TABLE seed            ADD COLUMN IF NOT EXISTS fecha DATE;
ALTER TABLE early_stage     ADD COLUMN IF NOT EXISTS fecha DATE;
ALTER TABLE growth_stage    ADD COLUMN IF NOT EXISTS fecha DATE;
ALTER TABLE expansion_stage ADD COLUMN IF NOT EXISTS fecha DATE;
ALTER TABLE exit            ADD COLUMN IF NOT EXISTS fecha DATE;

-- 2) Reglas: fechas no futuras (integridad temporal)
ALTER TABLE fundo
  DROP CONSTRAINT IF EXISTS chk_fundo_fecha_no_futura;
ALTER TABLE fundo
  ADD CONSTRAINT chk_fundo_fecha_no_futura
  CHECK (fecha <= CURRENT_DATE);

ALTER TABLE participa
  DROP CONSTRAINT IF EXISTS chk_participa_fecha_union_no_futura;
ALTER TABLE participa
  ADD CONSTRAINT chk_participa_fecha_union_no_futura
  CHECK (fecha_union <= CURRENT_DATE);

ALTER TABLE seed
  DROP CONSTRAINT IF EXISTS chk_seed_fecha_no_futura;
ALTER TABLE seed
  ADD CONSTRAINT chk_seed_fecha_no_futura
  CHECK (fecha <= CURRENT_DATE);

ALTER TABLE early_stage
  DROP CONSTRAINT IF EXISTS chk_early_stage_fecha_no_futura;
ALTER TABLE early_stage
  ADD CONSTRAINT chk_early_stage_fecha_no_futura
  CHECK (fecha <= CURRENT_DATE);

ALTER TABLE growth_stage
  DROP CONSTRAINT IF EXISTS chk_growth_stage_fecha_no_futura;
ALTER TABLE growth_stage
  ADD CONSTRAINT chk_growth_stage_fecha_no_futura
  CHECK (fecha <= CURRENT_DATE);

ALTER TABLE expansion_stage
  DROP CONSTRAINT IF EXISTS chk_expansion_stage_fecha_no_futura;
ALTER TABLE expansion_stage
  ADD CONSTRAINT chk_expansion_stage_fecha_no_futura
  CHECK (fecha <= CURRENT_DATE);

ALTER TABLE exit
  DROP CONSTRAINT IF EXISTS chk_exit_fecha_no_futura;
ALTER TABLE exit
  ADD CONSTRAINT chk_exit_fecha_no_futura
  CHECK (fecha <= CURRENT_DATE);

-- 3) Reglas: fechas de contratos no futuras
ALTER TABLE contratoinversionista_early
  DROP CONSTRAINT IF EXISTS chk_cinv_early_fecha_no_futura;
ALTER TABLE contratoinversionista_early
  ADD CONSTRAINT chk_cinv_early_fecha_no_futura
  CHECK (fecha <= CURRENT_DATE);

ALTER TABLE contratoinversionista_growth
  DROP CONSTRAINT IF EXISTS chk_cinv_growth_fecha_no_futura;
ALTER TABLE contratoinversionista_growth
  ADD CONSTRAINT chk_cinv_growth_fecha_no_futura
  CHECK (fecha <= CURRENT_DATE);

ALTER TABLE contratoinversionista_expansion
  DROP CONSTRAINT IF EXISTS chk_cinv_expansion_fecha_no_futura;
ALTER TABLE contratoinversionista_expansion
  ADD CONSTRAINT chk_cinv_expansion_fecha_no_futura
  CHECK (fecha <= CURRENT_DATE);

ALTER TABLE contratogobierno_early
  DROP CONSTRAINT IF EXISTS chk_cgob_early_fecha_no_futura;
ALTER TABLE contratogobierno_early
  ADD CONSTRAINT chk_cgob_early_fecha_no_futura
  CHECK (fecha <= CURRENT_DATE);

ALTER TABLE contratogobierno_growth
  DROP CONSTRAINT IF EXISTS chk_cgob_growth_fecha_no_futura;
ALTER TABLE contratogobierno_growth
  ADD CONSTRAINT chk_cgob_growth_fecha_no_futura
  CHECK (fecha <= CURRENT_DATE);

ALTER TABLE contratogobierno_expansion
  DROP CONSTRAINT IF EXISTS chk_cgob_expansion_fecha_no_futura;
ALTER TABLE contratogobierno_expansion
  ADD CONSTRAINT chk_cgob_expansion_fecha_no_futura
  CHECK (fecha <= CURRENT_DATE);

ALTER TABLE contratoorganizacion_early
  DROP CONSTRAINT IF EXISTS chk_corg_early_fecha_no_futura;
ALTER TABLE contratoorganizacion_early
  ADD CONSTRAINT chk_corg_early_fecha_no_futura
  CHECK (fecha <= CURRENT_DATE);

ALTER TABLE contratoorganizacion_growth
  DROP CONSTRAINT IF EXISTS chk_corg_growth_fecha_no_futura;
ALTER TABLE contratoorganizacion_growth
  ADD CONSTRAINT chk_corg_growth_fecha_no_futura
  CHECK (fecha <= CURRENT_DATE);

ALTER TABLE contratoorganizacion_expansion
  DROP CONSTRAINT IF EXISTS chk_corg_expansion_fecha_no_futura;
ALTER TABLE contratoorganizacion_expansion
  ADD CONSTRAINT chk_corg_expansion_fecha_no_futura
  CHECK (fecha <= CURRENT_DATE);
