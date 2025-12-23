
-- 01_indexes_minimos.sql


-- 1) Join principal: incubadora -> startup
CREATE INDEX IF NOT EXISTS idx_startup_id_incubadora
ON startup (id_incubadora);

-- 2) Cadena de etapas (joins frecuentes)
CREATE INDEX IF NOT EXISTS idx_seed_id_startup
ON seed (id_startup);

CREATE INDEX IF NOT EXISTS idx_early_id_seed
ON early_stage (id_seed);

CREATE INDEX IF NOT EXISTS idx_growth_id_early
ON growth_stage (id_early_stage);

CREATE INDEX IF NOT EXISTS idx_expansion_id_growth
ON expansion_stage (id_growth_stage);

CREATE INDEX IF NOT EXISTS idx_exit_id_expansion
ON exit (id_expansion_stage);

-- 3) Filtros temporales (estancamiento / series de tiempo)
CREATE INDEX IF NOT EXISTS idx_early_fecha
ON early_stage (fecha);

-- 4) Contratos: joins por etapa 
CREATE INDEX IF NOT EXISTS idx_cinv_early_stage
ON contratoinversionista_early (id_early_stage);

CREATE INDEX IF NOT EXISTS idx_cgob_early_stage
ON contratogobierno_early (id_early_stage);

CREATE INDEX IF NOT EXISTS idx_corg_early_stage
ON contratoorganizacion_early (id_early_stage);

CREATE INDEX IF NOT EXISTS idx_cinv_growth_stage
ON contratoinversionista_growth (id_growth_stage);

CREATE INDEX IF NOT EXISTS idx_cgob_growth_stage
ON contratogobierno_growth (id_growth_stage);

CREATE INDEX IF NOT EXISTS idx_corg_growth_stage
ON contratoorganizacion_growth (id_growth_stage);

CREATE INDEX IF NOT EXISTS idx_cinv_expansion_stage
ON contratoinversionista_expansion (id_expansion_stage);

CREATE INDEX IF NOT EXISTS idx_cgob_expansion_stage
ON contratogobierno_expansion (id_expansion_stage);

CREATE INDEX IF NOT EXISTS idx_corg_expansion_stage
ON contratoorganizacion_expansion (id_expansion_stage);

-- 5) Contratos: filtros por fecha 
CREATE INDEX IF NOT EXISTS idx_cinv_early_fecha
ON contratoinversionista_early (fecha);

CREATE INDEX IF NOT EXISTS idx_cinv_growth_fecha
ON contratoinversionista_growth (fecha);

CREATE INDEX IF NOT EXISTS idx_cinv_expansion_fecha
ON contratoinversionista_expansion (fecha);

CREATE INDEX IF NOT EXISTS idx_cgob_early_fecha
ON contratogobierno_early (fecha);

CREATE INDEX IF NOT EXISTS idx_cgob_growth_fecha
ON contratogobierno_growth (fecha);

CREATE INDEX IF NOT EXISTS idx_cgob_expansion_fecha
ON contratogobierno_expansion (fecha);

CREATE INDEX IF NOT EXISTS idx_corg_early_fecha
ON contratoorganizacion_early (fecha);

CREATE INDEX IF NOT EXISTS idx_corg_growth_fecha
ON contratoorganizacion_growth (fecha);

CREATE INDEX IF NOT EXISTS idx_corg_expansion_fecha
ON contratoorganizacion_expansion (fecha);
