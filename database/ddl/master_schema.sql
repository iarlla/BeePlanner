-- Criar tabelas primárias (Dimensões)
CREATE TABLE IF NOT EXISTS dim_subcategorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    area_vida VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_frequencias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    filtro_dias_semana VARCHAR(20),
    filtro_dia_mes INT
);

CREATE TABLE IF NOT EXISTS dim_metas (
    id SERIAL PRIMARY KEY,
    subcategoria_id INT REFERENCES dim_subcategorias(id) ON DELETE CASCADE,
    frequencia_id INT REFERENCES dim_frequencias(id) ON DELETE RESTRICT,
    titulo VARCHAR(255) NOT NULL,
    total_dias_100 INT NOT NULL,
    alvo_75_percent INT NOT NULL
);

-- Criar tabelas operacionais (Fato e Diário)
CREATE TABLE IF NOT EXISTS fact_execucoes (
    id SERIAL PRIMARY KEY,
    meta_id INT REFERENCES dim_metas(id) ON DELETE CASCADE,
    data_conclusao DATE NOT NULL,
    fonte_origem VARCHAR(50) DEFAULT 'PWA App',
    CONSTRAINT unique_meta_dia UNIQUE(meta_id, data_conclusao)
);

CREATE TABLE IF NOT EXISTS diario_bordo (
    id SERIAL PRIMARY KEY,
    data_diario DATE NOT NULL UNIQUE,
    dia_ano INT NOT NULL,
    semana_ano INT NOT NULL,
    texto_completo TEXT NOT NULL
);

-- ==========================================================
-- OPERAÇÕES CRUD BÁSICAS (Exemplos reutilizáveis no Flet)
-- ==========================================================

-- READ: View para alimentar o Dashboard
CREATE OR REPLACE VIEW vw_dashboard_final AS
SELECT
    m.id AS meta_id,
    m.titulo,
    c.nome AS subcategoria,
    m.total_dias_100,
    m.alvo_75_percent,
    COUNT(e.id) AS total_realizado,
    ROUND((COUNT(e.id)::NUMERIC / m.alvo_75_percent) * 100, 2) AS progresso_75
FROM dim_metas m
JOIN dim_subcategorias c ON m.subcategoria_id = c.id
LEFT JOIN fact_execucoes e ON m.id = e.meta_id
GROUP BY m.id, m.titulo, c.nome, m.total_dias_100, m.alvo_75_percent;

-- CREATE / UPDATE: Salvar Ata Diária (Upsert idempotente)
-- INSERT INTO diario_bordo (data_diario, dia_ano, semana_ano, texto_completo) VALUES (...)
-- ON CONFLICT (data_diario) DO UPDATE SET texto_completo = EXCLUDED.texto_completo;

-- DELETE: Remover Check-in errado
-- DELETE FROM fact_execucoes WHERE meta_id = %s AND data_conclusao = %s;