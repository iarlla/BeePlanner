CREATE OR REPLACE VIEW vw_dashboard_final AS
SELECT 
    sub.area_vida,
    sub.nome AS subcategoria,
    exp.titulo,
    exp.ano,
    exp.total_dias_100,
    exp.alvo_75_percent,
    COUNT(exe.id) AS total_realizado,
    -- Porcentagem de conclusão em relação ao ano todo
    ROUND((COUNT(exe.id)::DECIMAL / NULLIF(exp.total_dias_100, 0)) * 100, 2) AS progresso_atual,
    -- Lógica Booleana/Status para os 75%
    CASE 
        WHEN COUNT(exe.id) >= exp.alvo_75_percent THEN '✅ META BATIDA'
        WHEN COUNT(exe.id) >= (exp.alvo_75_percent * 0.8) THEN '⚠️ ATENÇÃO'
        ELSE '❌ ABAIXO DOS 75%'
    END AS status_75
FROM vw_expectativa_metas exp
JOIN dim_metas m ON exp.meta_id = m.id
JOIN dim_subcategorias sub ON m.subcategoria_id = sub.id
LEFT JOIN fact_execucoes exe ON m.id = exe.meta_id 
    AND EXTRACT(YEAR FROM exe.data_conclusao) = exp.ano
GROUP BY 
    sub.area_vida, sub.nome, exp.meta_id, exp.titulo, exp.ano, 
    exp.total_dias_100, exp.alvo_75_percent;