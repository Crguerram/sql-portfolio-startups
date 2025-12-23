--consulta7
WITH inv_dates AS (
  SELECT fecha, monto FROM contratoinversionista_early
  UNION ALL SELECT fecha, monto FROM contratoinversionista_growth
  UNION ALL SELECT fecha, monto FROM contratoinversionista_expansion
  UNION ALL SELECT fecha, monto FROM contratogobierno_early
  UNION ALL SELECT fecha, monto FROM contratogobierno_growth
  UNION ALL SELECT fecha, monto FROM contratogobierno_expansion
  UNION ALL SELECT fecha, monto FROM contratoorganizacion_early
  UNION ALL SELECT fecha, monto FROM contratoorganizacion_growth
  UNION ALL SELECT fecha, monto FROM contratoorganizacion_expansion
),
by_month AS (
  SELECT
    DATE_TRUNC('month', fecha)::date AS mes,
    round(SUM(monto),2) AS inversion_mensual
  FROM inv_dates
  GROUP BY 1
)
SELECT
  mes,
  inversion_mensual,
  SUM(inversion_mensual) OVER (ORDER BY mes) AS inversion_acumulada
FROM by_month
ORDER BY mes;
