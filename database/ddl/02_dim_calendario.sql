CREATE TABLE dim_calendario (
    data_id DATE PRIMARY KEY,
    ano INT NOT NULL,
    mes INT NOT NULL,
    dia INT NOT NULL,
    dia_semana INT NOT NULL, -- 0=Dom, 1=Seg, ..., 6=Sáb
    is_fim_semana BOOLEAN,
    is_bissexto BOOLEAN
);

-- Script para popular (Exemplo Postgres para 2026-2030)
INSERT INTO dim_calendario (data_id, ano, mes, dia, dia_semana, is_fim_semana, is_bissexto)
SELECT 
    datum AS data_id,
    EXTRACT(YEAR FROM datum) AS ano,
    EXTRACT(MONTH FROM datum) AS mes,
    EXTRACT(DAY FROM datum) AS dia,
    EXTRACT(DOW FROM datum) AS dia_semana,
    CASE WHEN EXTRACT(DOW FROM datum) IN (0, 6) THEN TRUE ELSE FALSE END,
    CASE WHEN (EXTRACT(YEAR FROM datum) % 4 = 0 AND EXTRACT(YEAR FROM datum) % 100 != 0) OR (EXTRACT(YEAR FROM datum) % 400 = 0) THEN TRUE ELSE FALSE END
FROM generate_series('2026-01-01'::date, '2030-12-31'::date, '1 day'::interval) datum;