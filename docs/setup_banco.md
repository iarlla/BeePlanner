# 🗄️ Setup do Banco de Dados - BeePlanner 1.0

Script unificado para criação do esquema relacional (Star Schema).

## 1. Criação do Database
No seu cliente SQL (pgAdmin, DBeaver ou psql), execute:

```sql
CREATE DATABASE beeplanner;
```

## 2. DDL (Definição de Tabelas)
Execute na ordem para respeitar as Foreign Keys.

```sql
-- 1. Dimensão: Subcategorias (Roda da Vida)
CREATE TABLE dim_subcategorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    area_vida VARCHAR(50) NOT NULL -- Pessoal, Profissional, Relacionamentos, Qualidade de vida
);

-- 2. Dimensão: Frequências (Regras de Agendamento)
CREATE TABLE dim_frequencias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    tipo VARCHAR(20) NOT NULL, -- DIARIO, SEMANAL, MENSAL, ESPECIFICO
    filtro_dias_semana VARCHAR(20), -- Ex: '1,3,5' (Seg, Qua, Sex)
    filtro_dia_mes INT,
    regra_sql_especial TEXT
);

-- 3. Dimensão: Calendário (Tempo)
CREATE TABLE dim_calendario (
    data_id DATE PRIMARY KEY,
    ano INT NOT NULL,
    mes INT NOT NULL,
    dia INT NOT NULL,
    dia_semana INT NOT NULL, -- 0=Dom, 1=Seg...
    is_fim_semana BOOLEAN,
    is_bissexto BOOLEAN
);

-- 4. Dimensão: Metas (Contrato Anual)
CREATE TABLE dim_metas (
    id SERIAL PRIMARY KEY,
    subcategoria_id INT REFERENCES dim_subcategorias(id),
    frequencia_id INT REFERENCES dim_frequencias(id),
    titulo VARCHAR(255) NOT NULL,
    status_notion VARCHAR(50),
    total_dias_100 INT,      -- Calculado via Python
    alvo_75_percent INT,     -- Calculado via Python
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Fato: Execuções (Log Diário)
CREATE TABLE fact_execucoes (
    id SERIAL PRIMARY KEY,
    meta_id INT REFERENCES dim_metas(id),
    data_conclusao DATE NOT NULL,
    fonte_origem VARCHAR(50) DEFAULT 'Google Tasks',
    observacao TEXT,
    CONSTRAINT unique_meta_dia UNIQUE(meta_id, data_conclusao)
);
```

## 3. Seeds (Dados Iniciais Obrigatórios)

```sql
-- Subcategorias
INSERT INTO dim_subcategorias (nome, area_vida) VALUES 
('Saúde e Disposição', 'Pessoal'), ('Intelectual', 'Pessoal'), 
('Recursos Financeiros', 'Profissional'), ('Contribuição Social', 'Profissional');

-- Frequências Básicas
INSERT INTO dim_frequencias (nome, tipo, filtro_dias_semana) VALUES 
('Diária', 'DIARIO', '0,1,2,3,4,5,6'),
('Semanal (Ter/Qui)', 'SEMANAL', '2,4');
```

## 4. Views (Lógica de Negócio)

```sql
CREATE OR REPLACE VIEW vw_dashboard_final AS
SELECT 
    m.titulo,
    m.total_dias_100,
    m.alvo_75_percent,
    COUNT(e.id) AS total_realizado,
    CASE 
        WHEN COUNT(e.id) >= m.alvo_75_percent THEN 'META BATIDA'
        ELSE 'EM PROGRESSO'
    END AS status
FROM dim_metas m
LEFT JOIN fact_execucoes e ON m.id = e.meta_id
GROUP BY m.titulo, m.total_dias_100, m.alvo_75_percent;
```

```sql

```

```sql

```