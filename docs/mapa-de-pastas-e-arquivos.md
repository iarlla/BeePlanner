# Estrutura de Pastas e Arquivos - BeePlanner

---

BeePlanner
├── database/
│   ├── ddl/
│   │   ├── 01_dim_subcategorias.sql    # Áreas da vida e subcategorias
│   │   ├── 02_dim_calendario.sql       # Calendário 2026-2030 (Bissextos)
│   │   ├── 03_dim_frequencias.sql      # Templates de agendamento e filtros
│   │   ├── 04_dim_metas.sql            # Definição das metas (vinculada ao Notion)
│   │   └── 05_fact_execucoes.sql       # Logs de conclusão (Google Tasks)
│   ├── views/
│   │   ├── vw_expectativa_metas.sql    # Cálculo de dias esperados (100% e 75%)
│   │   └── vw_dashboard_final.sql      # Join Realidade vs. Expectativa
│   └── seeds/
│       └── initial_data.sql            # Inserts iniciais de subcategorias e frequências
├── scripts/
│   ├── python/
│   │   ├── calc_metas_2026.py          # Script de cálculo logístico das metas
│   │   └── generate_calendar.py        # Gerador de dados para dim_calendario
│   └── apps_script/
│       └── google_tasks_sync.gs        # Integrador API Google Tasks -> DB
├── data/
│   ├── raw/
│   │   ├── notion_metas_export.csv     # Seu arquivo original do Notion
│   │   └── google_tasks_dump.json      # Backup temporário de tarefas
│   └── processed/
│       └── metas_calculadas_2026.csv   # Output do Python pronto para o SQL
└── docs/
    └── dashboard_blueprint.md          # Guia de configuração do Looker Studio