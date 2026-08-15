-- ==========================================================
-- 1. DDL (Data Definition Language) - Criação da Estrutura
-- ==========================================================
BEGIN;

DROP TABLE IF EXISTS fact_execucoes CASCADE;
DROP TABLE IF EXISTS dim_metas CASCADE;
DROP TABLE IF EXISTS dim_eixos CASCADE;
DROP TABLE IF EXISTS dim_quadrantes CASCADE;
DROP TABLE IF EXISTS dim_frequencias CASCADE;
DROP TABLE IF EXISTS configuracao_roda CASCADE;
DROP TABLE IF EXISTS diario_bordo CASCADE;

CREATE TABLE configuracao_roda (
    id_config SERIAL PRIMARY KEY,
    nome_config VARCHAR(100) NOT NULL,
    qnt_eixos_min INT DEFAULT 3,
    qnt_eixos_max INT DEFAULT 12
);

CREATE TABLE dim_quadrantes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cor VARCHAR(20),
    descricao TEXT
);

CREATE TABLE dim_eixos (
    id_eixo SERIAL PRIMARY KEY,
    id_config INT REFERENCES configuracao_roda(id_config) ON DELETE CASCADE,
    quadrante_id INT REFERENCES dim_quadrantes(id),
    nome_eixo VARCHAR(100) NOT NULL,
    icone VARCHAR(100),
    peso NUMERIC(3,1),
    cor VARCHAR(20),
    ordem_apresentacao INT NOT NULL
);

CREATE TABLE dim_frequencias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL
);

CREATE TABLE dim_metas (
    id SERIAL PRIMARY KEY,
    eixo_id INT REFERENCES dim_eixos(id_eixo) ON DELETE CASCADE,
    frequencia_id INT REFERENCES dim_frequencias(id) ON DELETE RESTRICT,
    titulo VARCHAR(255) NOT NULL,
    total_dias_100 INT NOT NULL,
    alvo_75_percent INT NOT NULL
);

CREATE TABLE fact_execucoes (
    id SERIAL PRIMARY KEY,
    meta_id INT REFERENCES dim_metas(id) ON DELETE CASCADE,
    data_conclusao DATE NOT NULL,
    fonte_origem VARCHAR(50) DEFAULT 'PWA App',
    CONSTRAINT unique_meta_dia UNIQUE(meta_id, data_conclusao)
);

CREATE TABLE diario_bordo (
    id SERIAL PRIMARY KEY,
    data_diario DATE NOT NULL UNIQUE,
    dia_ano INT NOT NULL,
    semana_ano INT NOT NULL,
    texto_completo TEXT NOT NULL
);

-- ==========================================================
-- 2. DML (Data Manipulation Language) - Inserção dos Dados
-- ==========================================================

-- Configuração Principal
INSERT INTO configuracao_roda (nome_config, qnt_eixos_min, qnt_eixos_max) 
VALUES ('Teia de Aranha (12 Eixos)', 3, 12);

-- Quadrantes (roda_da_vida-quadrante.csv)
INSERT INTO dim_quadrantes (id, nome, cor, descricao) VALUES
(1, 'Qualidade de Vida', '#8FB6FF', 'Esta macroárea analisa a sua satisfação em desfrutar a vida, expandir a mente e conectar-se internamente.'),
(2, 'Saúde', '#90EE90', 'Esta macroárea foca em manter o seu corpo, mente e emoções funcionando corretamente.'),
(3, 'Conexões Sociais', '#FFB6C1', 'Esta macroárea mede a qualidade da sua convivência e afeto com as pessoas ao redor.'),
(4, 'Profissional', '#FFD700', 'Esta macroárea avalia o seu crescimento no trabalho, sua segurança financeira e legado.');

-- Eixos / Áreas (roda_da_vida-area.csv)
INSERT INTO dim_eixos (id_eixo, id_config, quadrante_id, nome_eixo, icone, peso, cor, ordem_apresentacao) VALUES
(1, 1, 1, 'Educação', 'fa-solid fa-graduation-cap', 8.3, '#8FB6FF', 1),
(2, 1, 1, 'Espiritualidade', 'fa-solid fa-praying-hands', 8.3, '#8FB6FF', 2),
(3, 1, 1, 'Lazer e Diversão', 'fa-solid fa-gamepad', 8.4, '#8FB6FF', 3),
(4, 1, 2, 'Atividades Físicas', 'fa-solid fa-dumbbell', 8.3, '#8FB6FF', 4),
(5, 1, 2, 'Equilíbrio emocional', 'fa-solid fa-brain', 8.3, '#8FB6FF', 5),
(6, 1, 2, 'Alimentação', 'fa-solid fa-apple-alt', 8.4, '#8FB6FF', 6),
(7, 1, 3, 'Vida Amorosa', 'fa-solid fa-heart', 8.3, '#FFB6C1', 7),
(8, 1, 3, 'Família', 'fa-solid fa-users', 8.3, '#FFB6C1', 8),
(9, 1, 2, 'Vida social', 'fa-solid fa-user-friends', 8.4, '#FFB6C1', 9),
(10, 1, 3, 'Carreira', 'fa-solid fa-briefcase', 8.3, '#FFD700', 10),
(11, 1, 3, 'Contribuição social', 'fa-solid fa-hands-helping', 8.3, '#FFD700', 11),
(12, 1, 3, 'Finanças Pessoais', 'fa-solid fa-wallet', 8.4, '#90EE90', 12);

-- Frequências Únicas Extraídas (roda_da_vida-metas.csv)
INSERT INTO dim_frequencias (id, nome, tipo) VALUES
(1, 'Diária - Todo dia', 'DIARIO'),
(2, 'Semanal - Terça e Quinta', 'SEMANAL'),
(3, 'Semanal - Quarta', 'SEMANAL'),
(4, 'Semanal - Domingo', 'SEMANAL'),
(5, 'Semanal - Domingo e Quarta', 'SEMANAL'),
(6, 'Semanal - Segunda a Sexta', 'SEMANAL'),
(7, 'Mensal - 1º Dia do Mês', 'MENSAL'),
(8, 'Semanal - Sábado', 'SEMANAL'),
(9, 'Mensal - 10º Dia Útil', 'MENSAL'),
(10, 'Semanal - Sexta', 'SEMANAL'),
(11, 'Mensal - 1º Sábado do Mês', 'MENSAL');

-- Metas (roda_da_vida-metas.csv)
INSERT INTO dim_metas (eixo_id, frequencia_id, titulo, total_dias_100, alvo_75_percent) VALUES
(1, 1, 'Estudar vocabulário técnico de inglês', 365, 274),
(1, 2, 'Praticar simulados para AZ-900 e ITIL 4', 104, 78),
(1, 3, 'Ler artigos sobre engenharia de dados', 52, 39),
(2, 1, 'Meditação ou reflexão matinal', 365, 274),
(2, 4, 'Leitura de textos inspiracionais', 52, 39),
(2, 1, 'Exercício de gratidão ao final do dia', 365, 274),
(3, 5, 'Ler novos capítulos de mangá', 104, 78),
(3, 1, 'Ouvir playlists de samba e pagode', 365, 274),
(3, 5, 'Assistir aos jogos do Flamengo', 104, 78),
(4, 6, 'Treino de musculação na academia', 260, 195),
(4, 2, 'Fazer cardio na escada', 104, 78),
(4, 1, 'Alongamento focado em quadril e lombar', 365, 274),
(5, 1, 'Pausas ativas durante o trabalho', 365, 274),
(5, 1, 'Desconectar de telas após as 22h', 365, 274),
(5, 7, 'Sessão de autocuidado ou terapia', 12, 9),
(6, 1, 'Tomar café da manhã com café passado', 365, 274),
(6, 1, 'Preparar lanches e barras de proteína', 365, 274),
(6, 1, 'Beber 2 litros de água', 365, 274),
(7, 8, 'Sair para um date ou festival de música', 52, 39),
(7, 9, 'Planejar as próximas viagens', 12, 9),
(7, 1, 'Tempo de qualidade sem celulares', 365, 274),
(8, 4, 'Almoço em família', 52, 39),
(8, 10, 'Ligar para parentes distantes', 52, 39),
(8, 8, 'Organizar e limpar o ambiente do lar', 52, 39),
(9, 8, 'Encontrar amigos para café ou treino conjunto', 52, 39),
(9, 2, 'Sessão de estudos ou projetos em grupo', 104, 78),
(9, 11, 'Participar de eventos sociais ou confraternizações', 12, 9),
(10, 10, 'Atualizar repositórios de projetos no GitHub', 52, 39),
(10, 4, 'Revisar automações de dados e scripts', 52, 39),
(10, 7, 'Preparar materiais de treinamento de sistemas', 12, 9),
(11, 3, 'Revisar pautas e materiais do STEM for Women', 52, 39),
(11, 9, 'Organizar cronograma de mentoria técnica', 12, 9),
(11, 2, 'Compartilhar conteúdo de tecnologia para iniciantes', 104, 78),
(12, 9, 'Revisar pagamentos de assinaturas e academia', 12, 9),
(12, 7, 'Separar reserva para o programa habitacional', 12, 9),
(12, 4, 'Registrar gastos e organizar fluxo de caixa', 52, 39);

COMMIT;