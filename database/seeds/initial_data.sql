-- ==========================================================
-- 1. POPULANDO SUBCATEGORIAS (RODA DA VIDA)
-- ==========================================================
INSERT INTO dim_subcategorias (nome, area_vida) VALUES 
('Saúde e Disposição', 'Pessoal'), 
('Intelectual', 'Pessoal'), 
('Equilíbrio Emocional', 'Pessoal'),
('Realização e Propósito', 'Profissional'), 
('Recursos Financeiros', 'Profissional'), 
('Contribuição Social', 'Profissional'),
('Vida Amorosa', 'Relacionamentos'), 
('Família', 'Relacionamentos'), 
('Vida Social', 'Relacionamentos'),
('Espiritualidade', 'Qualidade de vida'), 
('Plenitude e Felicidade', 'Qualidade de vida'), 
('Criatividade Hobbies e Diversão', 'Qualidade de vida');

-- ==========================================================
-- 2. POPULANDO FREQUÊNCIAS (REGRAS DE FILTRO)
-- ==========================================================
INSERT INTO dim_frequencias (nome, tipo, filtro_dias_semana, filtro_dia_mes, regra_sql_especial) VALUES 
-- Diários
('Todo dia', 'DIARIO', '0,1,2,3,4,5,6', NULL, NULL),

-- Semanais (Baseado no seu CSV: Sunday=0, Monday=1, Tuesday=2, Wednesday=3, Thursday=4, Friday=5, Saturday=6)
('Terça e Quinta', 'SEMANAL', '2,4', NULL, NULL),
('Segunda e Sexta', 'SEMANAL', '1,5', NULL, NULL),
('Domingo e Quarta', 'SEMANAL', '0,3', NULL, NULL),
('Domingo, Terça e Quinta', 'SEMANAL', '0,2,4', NULL, NULL),
('Quarta', 'SEMANAL', '3', NULL, NULL),

-- Mensais
('10º Dia Útil', 'MENSAL', NULL, 10, NULL),
('1º Dia do Mês', 'MENSAL', NULL, 1, NULL),

-- Regras Especiais
('1º Domingo do Mês', 'ESPECIFICO', '0', NULL, 'EXTRACT(DAY FROM data_id) <= 7');

-- ==========================================================
-- 3. EXEMPLO DE VÍNCULO DE METAS (OPCIONAL NESTE ARQUIVO)
-- ==========================================================
-- Aqui você vincula os IDs gerados acima. 
-- Ex: Supondo que 'Saúde' seja ID 1 e 'Diária' seja ID 1
INSERT INTO dim_metas (subcategoria_id, frequencia_id, titulo, nivel_de_realidade) VALUES 
(1, 1, '30 min de Exercício físico', 'goal'),
(10, 1, '1 capítulo da Bíblia', 'reality');