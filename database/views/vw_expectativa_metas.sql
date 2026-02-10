CREATE OR REPLACE VIEW vw_expectativa_metas AS
SELECT 
    m.id AS meta_id,
    m.titulo,
    c.ano,
    COUNT(c.data_id) AS total_dias_100,
    -- Cálculo da meta de 75%
    ROUND(COUNT(c.data_id) * 0.75) AS alvo_75_percent
FROM dim_metas m
JOIN dim_frequencias f ON m.frequencia_id = f.id
JOIN dim_calendario c ON (
    -- Regra Diária
    (f.tipo = 'DIARIO') OR
    
    -- Regra Semanal: verifica se o dia da semana do calendário está na lista da frequência
    (f.tipo = 'SEMANAL' AND POSITION(CAST(c.dia_semana AS TEXT) IN f.filtro_dias_semana) > 0) OR
    
    -- Regra Mensal: verifica se o dia do mês coincide
    (f.tipo = 'MENSAL' AND c.dia = f.filtro_dia_mes) OR
    
    -- Regras Específicas (ex: 1º Domingo)
    (f.tipo = 'ESPECIFICO' AND 
        CASE 
            WHEN f.nome ILIKE '%1º Domingo%' THEN (c.dia_semana = 0 AND c.dia <= 7)
            ELSE FALSE 
        END)
)
GROUP BY m.id, m.titulo, c.ano;