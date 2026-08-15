
-- ==========================================================
-- 1. DDL (Data Definition Language) - Criação da Estrutura
-- ==========================================================

-- Tabela para armazenar as configurações (templates) da Roda da Vida
-- Permite que o sistema tenha predefinições como "Quadrilátero", "Hexágono", etc.
CREATE TABLE configuracao_roda (
    id_config SERIAL PRIMARY KEY,
    nome_config VARCHAR(100) NOT NULL, -- Ex: 'Quadrilátero', 'Hexágono', 'Personalizado'
    qnt_eixos_min INT DEFAULT 3 CHECK (qnt_eixos_min >= 3),
    qnt_eixos_max INT DEFAULT 12 CHECK (qnt_eixos_max <= 12)
);

-- Tabela para os Eixos (Áreas) dinâmicos da Roda da Vida
-- Substitui a antiga 'dim_subcategorias' com nomes fixos
CREATE TABLE dim_eixos (
    id_eixo SERIAL PRIMARY KEY,
    id_config INT REFERENCES configuracao_roda(id_config) ON DELETE CASCADE,
    nome_eixo VARCHAR(100) NOT NULL, -- Ex: 'Saúde', 'Finanças', 'Espiritualidade'
    ordem_apresentacao INT NOT NULL CHECK (ordem_apresentacao >= 1 AND ordem_apresentacao <= 12),
    -- Garante que dentro de uma mesma configuração (ex: Hexágono) não haja ordens repetidas
    UNIQUE(id_config, ordem_apresentacao)
);

-- (Mantemos a tabela de frequências que você já tinha)
CREATE TABLE dim_frequencias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    filtro_dias_semana VARCHAR(20),
    filtro_dia_mes INT
);

-- Tabela de Metas ajustada para apontar para o eixo dinâmico
CREATE TABLE dim_metas (
    id SERIAL PRIMARY KEY,
    eixo_id INT REFERENCES dim_eixos(id_eixo) ON DELETE CASCADE,
    frequencia_id INT REFERENCES dim_frequencias(id) ON DELETE RESTRICT,
    titulo VARCHAR(255) NOT NULL,
    total_dias_100 INT NOT NULL,
    alvo_75_percent INT NOT NULL
);

-- Tabela de Execuções (Fato)
CREATE TABLE fact_execucoes (
    id SERIAL PRIMARY KEY,
    meta_id INT REFERENCES dim_metas(id) ON DELETE CASCADE,
    data_conclusao DATE NOT NULL,
    fonte_origem VARCHAR(50) DEFAULT 'PWA App',
    CONSTRAINT unique_meta_dia UNIQUE(meta_id, data_conclusao)
);

-- ==========================================================
-- 2. DML (Data Manipulation Language) - Inserção de Dados (CRUD)
-- ==========================================================

-- A) CREATE: Inserindo as opções de Roda da Vida

-- Configuração 1: Triângulo
INSERT INTO configuracao_roda (nome_config) VALUES ('Triângulo (3 Eixos)');
-- Configuração 2: Quadrilátero
INSERT INTO configuracao_roda (nome_config) VALUES ('Quadrilátero (4 Eixos)');
-- Configuração 3: Hexágono
INSERT INTO configuracao_roda (nome_config) VALUES ('Hexágono (6 Eixos)');

-- Inserindo os Eixos para o 'Quadrilátero' (Assumindo id_config = 2)
INSERT INTO dim_eixos (id_config, nome_eixo, ordem_apresentacao) VALUES
(2, 'Pessoal', 1),
(2, 'Profissional', 2),
(2, 'Relacionamentos', 3),
(2, 'Qualidade de Vida', 4);

-- Inserindo os Eixos para o 'Hexágono' (Assumindo id_config = 3)
INSERT INTO dim_eixos (id_config, nome_eixo, ordem_apresentacao) VALUES
(3, 'Tempo', 1),
(3, 'Conexão', 2),
(3, 'Disposição', 3),
(3, 'Investimento', 4),
(3, 'Finanças', 5),
(3, 'Trabalho', 6);

-- Inserindo frequências base
INSERT INTO dim_frequencias (nome, tipo) VALUES ('Todo dia', 'DIARIO');

-- Inserindo uma Meta vinculada ao Eixo 'Pessoal' do Quadrilátero (id_eixo = 1)
INSERT INTO dim_metas (eixo_id, frequencia_id, titulo, total_dias_100, alvo_75_percent) 
VALUES (1, 1, 'Meditação Diária', 365, 274);

-- Registrando uma execução
INSERT INTO fact_execucoes (meta_id, data_conclusao) VALUES (1, '2026-06-27');

-- B) READ (Visualizar a Roda Atual)
-- Consulta para gerar os dados do Radar (calcula o progresso por Eixo)
-- Esta query é dinâmica: se você filtrar pelo id_config = 3, ela trará os 6 eixos.
CREATE OR REPLACE VIEW vw_radar_roda_da_vida AS
SELECT 
    c.nome_config,
    e.ordem_apresentacao,
    e.nome_eixo,
    COUNT(m.id) as total_metas_eixo,
    COALESCE(SUM(m.alvo_75_percent), 0) as alvo_total_eixo,
    COUNT(f.id) as execucoes_realizadas,
    CASE 
        WHEN SUM(m.alvo_75_percent) > 0 THEN ROUND((COUNT(f.id)::NUMERIC / SUM(m.alvo_75_percent)) * 100, 2)
        ELSE 0 
    END as percentual_preenchimento
FROM dim_eixos e
JOIN configuracao_roda c ON e.id_config = c.id_config
LEFT JOIN dim_metas m ON e.id_eixo = m.eixo_id
LEFT JOIN fact_execucoes f ON m.id = f.meta_id
GROUP BY c.nome_config, e.ordem_apresentacao, e.nome_eixo
ORDER BY c.nome_config, e.ordem_apresentacao;

-- C) UPDATE
-- Usuário decidiu renomear 'Qualidade de Vida' para 'Saúde e Lazer' (id_eixo = 4)
UPDATE dim_eixos 
SET nome_eixo = 'Saúde e Lazer' 
WHERE id_eixo = 4;

-- D) DELETE
-- Usuário quer apagar um check-in feito errado
DELETE FROM fact_execucoes WHERE meta_id = 1 AND data_conclusao = '2026-06-27';

-- ==========================================================
-- 3. TCL (Transaction Control Language)
-- ==========================================================
-- Como o sistema tem sincronização em nuvem e alteração dinâmica de eixos,
-- transações são essenciais para evitar que o banco fique inconsistente se a internet cair.

BEGIN; -- Inicia a transação
-- Suponha que o usuário quer mudar a configuração inteira.
-- Primeiro deletamos as metas do eixo antigo (ou movemos, mas aqui é um exemplo de delete em cascata)
DELETE FROM dim_eixos WHERE id_config = 2; 
-- Inserimos a nova configuração
INSERT INTO dim_eixos (id_config, nome_eixo, ordem_apresentacao) VALUES (1, 'Nova Área', 1);
COMMIT; -- Se tudo deu certo, salva no banco.
-- Se desse erro, usaríamos ROLLBACK;

-- ==========================================================
-- 4. DCL (Data Control Language)
-- ==========================================================
-- (Normalmente configurado no servidor, mas é bom ter no repositório)
-- Suponha que a API do Flet conecte usando o usuário 'beeplanner_app'
CREATE USER beeplanner_app WITH PASSWORD 'senha_segura';
GRANT CONNECT ON DATABASE beeplanner TO beeplanner_app;
GRANT USAGE ON SCHEMA public TO beeplanner_app;
-- Permite leitura e escrita apenas nas tabelas operacionais
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO beeplanner_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO beeplanner_app;
