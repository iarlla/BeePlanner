CREATE TABLE dim_frequencias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    tipo VARCHAR(20) NOT NULL, -- DIARIO, SEMANAL, MENSAL, ESPECIFICO
    filtro_dias_semana VARCHAR(20), -- '1,3,5'
    filtro_dia_mes INT,
    regra_especial TEXT
);

INSERT INTO dim_frequencias (nome, tipo, filtro_dias_semana, filtro_dia_mes) VALUES 
('Todo dia', 'DIARIO', '0,1,2,3,4,5,6', NULL),
('Terça e Quinta', 'SEMANAL', '2,4', NULL),
('Segunda e Sexta', 'SEMANAL', '1,5', NULL),
('Dia 10 do mês', 'MENSAL', NULL, 10);