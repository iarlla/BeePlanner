CREATE TABLE fact_execucoes (
    id SERIAL PRIMARY KEY,
    meta_id INT REFERENCES dim_metas(id),
    data_conclusao DATE NOT NULL,
    fonte_origem VARCHAR(50) DEFAULT 'Google Tasks',
    observacao TEXT,
    -- Restrição para garantir apenas um check-in por meta por dia
    CONSTRAINT unique_meta_dia UNIQUE(meta_id, data_conclusao)
);