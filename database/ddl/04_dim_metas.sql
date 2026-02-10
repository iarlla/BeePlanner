CREATE TABLE dim_metas (
    id SERIAL PRIMARY KEY,
    subcategoria_id INT REFERENCES dim_subcategorias(id),
    frequencia_id INT REFERENCES dim_frequencias(id),
    titulo VARCHAR(255) NOT NULL,
    nivel_de_realidade VARCHAR(50), -- delusion, dream, goal, reality, 
    total_dias_100 INT,      -- Calculado via Python
    alvo_75_percent INT,     -- Calculado via Python
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Exemplo de inserção baseada no seu Notion
INSERT INTO dim_metas (subcategoria_id, frequencia_id, titulo, nivel_de_realidade) VALUES 
(10, 1, '1 capítulo da Bíblia', 'reality'),
(5, 4, 'Guardar dinheiro', 'goal'),
(2, 2, 'Podcast in English', 'goal');