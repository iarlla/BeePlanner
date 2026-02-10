# Blueprint: Dashboard Roda da Vida 2026

Este documento descreve como configurar a visualização dos dados no **Looker Studio** utilizando a view `vw_dashboard_final`.

## 1. Conexão de Dados
- **Fonte:** PostgreSQL / BigQuery / Google Sheets (conectado à sua View SQL).
- **Tabela Principal:** `vw_dashboard_final`.

## 2. Gráficos Principais

### A. Gráfico de Radar (A Roda da Vida)
- **Tipo:** Radar Chart (disponível em visualizações da comunidade).
- **Dimensão:** `subcategoria`.
- **Métrica:** `progresso_atual`.
- **Filtro:** `ano = 2026`.
- **Objetivo:** Visualizar o equilíbrio entre as áreas. O centro é 0% e a borda é 100%.

### B. Scorecards de Meta (75%)
- **Métrica:** `total_realizado` vs `alvo_75_percent`.
- **Estilo:** Use um gráfico de **Medidor (Gauge)**.
- **Configuração de Cores:**
    - 0 a 60%: Vermelho.
    - 60% a 74%: Amarelo.
    - 75% a 100%: Verde (Meta Atingida).

### C. Tabela de Detalhamento
- **Colunas:** `titulo`, `subcategoria`, `total_realizado`, `meta_75`, `status_75`.
- **Formatação Condicional:** Aplique cores na coluna `status_75` para identificar rapidamente onde focar.

## 3. Filtros Recomendados
- **Dropdown:** `area_vida` (Pessoal, Profissional, etc).
- **Dropdown:** `status_75` (Para ver apenas o que está "Abaixo da Meta").

## 4. Fórmula Customizada (Opcional no Looker)
Caso queira calcular a "Saúde da Categoria" em tempo real:
`AVG(progresso_atual)` agrupado por `area_vida`.