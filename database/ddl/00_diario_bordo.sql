CREATE TABLE diario_bordo (
    id SERIAL PRIMARY KEY,
    data_diario DATE NOT NULL UNIQUE, -- Uma ata por dia
    dia_ano INT,                      -- Ex: 45
    semana_ano INT,                   -- Ex: 7
    texto_completo TEXT,              -- O conteúdo do email
    sentimento_score DECIMAL(3,2),    -- Futuro: -1.0 (triste) a +1.0 (feliz)
    tags_detectadas TEXT[],           -- Ex: {'cansada', 'focada', 'família'}
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);