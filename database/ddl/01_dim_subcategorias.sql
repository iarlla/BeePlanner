-- Criação da tabela de dimensões das subcategorias
CREATE TABLE dim_subcategorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    area_vida VARCHAR(50) NOT NULL -- Pessoal, Profissional, Relacionamentos, Qualidade de vida
);

-- Inserção dos dados mestre
INSERT INTO dim_subcategorias (nome, area_vida) VALUES 
('Saúde e Disposição', 'Pessoal'), ('Intelectual', 'Pessoal'), ('Equilíbrio Emocional', 'Pessoal'),
('Realização e Propósito', 'Profissional'), ('Recursos Financeiros', 'Profissional'), ('Contribuição Social', 'Profissional'),
('Vida Amorosa', 'Relacionamentos'), ('Família', 'Relacionamentos'), ('Vida Social', 'Relacionamentos'),
('Espiritualidade', 'Qualidade de vida'), ('Plenitude e Felicidade', 'Qualidade de vida'), ('Criatividade Hobbies e Diversão', 'Qualidade de vida');