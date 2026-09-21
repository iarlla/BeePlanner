# Diagnóstico de Erros e Plano de Melhorias — BeePlanner

> **Projeto**: BeePlanner (Life Engineering 2026: Roda da Vida & Tracker)  
> **Data da Análise**: 21 de Setembro de 2026  
> **Status**: Diagnóstico Concluído — Ação Recomendada

---

## 1. Resumo Executivo

O **BeePlanner** é um sistema de engenharia pessoal projetado para planejar, monitorar e registrar o progresso de metas pessoais/profissionais em 2026, com foco no atingimento de **75% de aderência**. O ecossistema abrange:
- Modelagem de dados relacional em **PostgreSQL** (Star Schema e Views dinâmicas).
- Scripts de automação em **Python** (Cálculo de metas, geradores de calendário, envio de e-mail diário com Tkinter/Psycopg2 e gráficos em Flet Canvas).
- Scripts de ingestão via **Google Apps Script** para sincronização com Google Tasks.
- Protótipos/Demos web interativos em **HTML/CSS/JS**.

A análise do código-fonte revelou um projeto conceitualmente forte, porém com **inconsistências graves de execução, scripts duplicados, erros de sintaxe SQL/Python e divergências de modelo de dados** entre scripts e banco.

---

## 2. Visão Geral da Estrutura Encontrada

A estrutura de arquivos do projeto apresenta uma duplicidade entre a raiz do diretório workspace e a subpasta `BeePlanner/`:

```text
/home/caju/github-iarlla/BeePlanner
├── agenda_email.py                   <-- [DUPLICADO / OBSOLETO] Versão antiga solta na raiz
├── create.sql                        <-- [ERRO DE SINTAXE SQL] FK apontando para tabela inexistente
├── insert.sql                        <-- [DUPLICADO] Script solto na raiz
├── syncTasksToDatabase.ty            <-- [ERRO DE EXTENSÃO E LÓGICA] Extensão .ty e filtro errado
├── view.sql                          <-- [DUPLICADO] Script solto na raiz
└── BeePlanner/                       <-- [REPOSITÓRIO PRINCIPAL]
    ├── .env / example.env
    ├── README.md
    ├── database/
    │   ├── ddl/                      <-- Schemas estáticos (master_schema.sql) vs dinâmicos (schema_dinamico.sql)
    │   ├── views/                    <-- vw_dashboard_final.sql, vw_expectativa_metas.sql
    │   └── seeds/                    <-- initial_data.sql
    ├── scripts/
    │   ├── python/                   <-- agenda_email.py, calc_metas_2026.py, desenhar_roda_dinamica.py, etc.
    │   ├── daily_ops/                <-- seed_from_csv.py (com erro de arquivo e SQLite)
    │   └── apps_script/              <-- google_tasks_sync.gs
    ├── demo/                         <-- Protótipos HTML/CSS/JS (dashboard, metas, roda da vida, etc.)
    └── docs/                         <-- Documentações do projeto
```

---

## 3. Diagnóstico Detalhado de Erros (Bug Report)

### 🔴 3.1. Erros Críticos no Banco de Dados (SQL DDL & Views)

1. **Falha de Chave Estrangeira em [create.sql](file:///home/caju/github-iarlla/BeePlanner/create.sql#L2-L40)**:
   - **Descrição**: A tabela de categorias é criada como `CREATE TABLE subcategorias (...);` (sem o prefixo `dim_`).
   - **Erro**: Na criação da tabela `dim_metas` (linha 35), há a instrução: `subcategoria_id INT REFERENCES dim_subcategorias(id)`.
   - **Impacto**: A execução do script falha com `ERROR: relation "dim_subcategorias" does not exist`.

2. **Divergência Arquitetural entre Modelo Estático vs. Modelo Dinâmico**:
   - **Descrição**: O projeto possui duas modelagens concorrentes no DDL:
     - Modelo Estático ([master_schema.sql](file:///home/caju/github-iarlla/BeePlanner/BeePlanner/database/ddl/master_schema.sql)): usa `dim_subcategorias` (`subcategoria_id`).
     - Modelo Dinâmico ([schema_dinamico.sql](file:///home/caju/github-iarlla/BeePlanner/BeePlanner/database/ddl/schema_dinamico.sql)): usa `dim_eixos` (`eixo_id`) e `configuracao_roda`.
   - **Impacto**: As views analíticas ([vw_dashboard_final.sql](file:///home/caju/github-iarlla/BeePlanner/BeePlanner/database/views/vw_dashboard_final.sql) e [vw_expectativa_metas.sql](file:///home/caju/github-iarlla/BeePlanner/BeePlanner/database/views/vw_expectativa_metas.sql)) dependem exclusivamente das tabelas e colunas do modelo estático (`dim_subcategorias`). Se o banco for populado com o `schema_dinamico.sql`, todas as views falham com erro de coluna inexistente (`m.subcategoria_id`).

---

### 🔴 3.2. Erros nos Scripts Python

1. **Sobrescrita Indevida de Configurações do `.env` em [BeePlanner/scripts/python/agenda_email.py](file:///home/caju/github-iarlla/BeePlanner/BeePlanner/scripts/python/agenda_email.py#L16-L44)**:
   - **Descrição**: Nas linhas 17–27, o script carrega as variáveis de ambiente com `os.getenv("DB_HOST")`, `os.getenv("EMAIL_ADDRESS")`, etc.
   - **Erro**: Imediatamente nas linhas 31–43, os dicionários `DB_CONFIG` e as variáveis de e-mail são **redefinidas** com strings fictícias hardcoded (`"teuemail@gmail.com"`, `"tuasenha"`, `"sua_senha_aqui"`).
   - **Impacto**: O script falha ao tentar conectar ao banco PostgreSQL ou autenticar no servidor SMTP do Gmail, ignorando o arquivo `.env`.

2. **`FileNotFoundError` em [BeePlanner/scripts/daily_ops/seed_from_csv.py](file:///home/caju/github-iarlla/BeePlanner/BeePlanner/scripts/daily_ops/seed_from_csv.py#L6)**:
   - **Descrição**: O script tenta ler o arquivo `'metas_12_areas.csv'`, que não existe no repositório.
   - **Impacto**: Lança exceção `FileNotFoundError` ao ser executado. O arquivo correto no projeto está em `data/raw/notion_metas_export.csv` ou `data/processed/metas_calculadas_2026.csv`.

3. **Incompatibilidade SQLite vs. PostgreSQL em `seed_from_csv.py`**:
   - **Descrição**: `seed_from_csv.py` utiliza a biblioteca nativa `sqlite3` (`sqlite3.connect('database/beeplanner.db')`) e placeholders `?`.
   - **Impacto**: Todo o projeto e DDLs usam PostgreSQL. Criar um banco SQLite desincroniza a arquitetura e gera inconsistência entre ambientes.

4. **Multiplicidade e Inconsistência nos Scripts de Calendário**:
   - **Descrição**: Existem 3 scripts concorrentes para tratar dimensão de tempo:
     - `generate_calendar.py`: Converte dia da semana Pandas para Domingo=0 (padrão SQL).
     - `Gerador_de_Calendário.py`: Mantém Segunda=0 (padrão Python/ISO).
     - `gerar_data_padrao.py`: Apenas imprime string formatada.
   - **Impacto**: Risco de cálculos incorretos de dias e metas dependendo de qual script é chamado pela esteira ETL.

---

### 🔴 3.3. Erros nos Scripts de Ingestão (Google Apps Script / Tasks API)

1. **Extensão Incorreta e Localização do Arquivo na Raiz**:
   - **Descrição**: O arquivo [syncTasksToDatabase.ty](file:///home/caju/github-iarlla/BeePlanner/syncTasksToDatabase.ty) possui a extensão `.ty` (digitação incorreta de `.gs`).
2. **Lógica de Filtro de Data Incorreta**:
   - **Descrição**: Na linha 11 de `syncTasksToDatabase.ty`, o parâmetro de busca de tarefas usa:
     `completedMin: new Date().toISOString()`.
   - **Impacto**: O script solicita apenas tarefas concluídas *após* o momento exato da execução, retornando sempre 0 tarefas.
   - **Nota**: O script interno [google_tasks_sync.gs](file:///home/caju/github-iarlla/BeePlanner/BeePlanner/scripts/apps_script/google_tasks_sync.gs#L12) já possui a correção adequada (`completedMin` de 24 horas atrás).

---

### 🟡 3.4. Problemas de Frontend & UI (Demo Web)

1. **Dados Estáticos/Mockados**:
   - As páginas em `BeePlanner/demo/view/` (`dashboard.html`, `metas.html`, `roda-da-vida.html`, `tarefas.html`) são protótipos em HTML puro com manipulação DOM básica, sem consumo de API ou dados dinâmicos do PostgreSQL.
2. **Ausência de Integração Backend**:
   - Não há um servidor web (FastAPI/Flask/Node) exposto para responder às requisições do frontend demo.

---

## 4. Plano Recomendado de Melhorias e Refatoração

### 🚀 4.1. Ações Imediatas (Hotfixes)

1. **Limpeza da Raiz do Repositório**:
   - Excluir os arquivos redundantes e errôneos da raiz (`create.sql`, `insert.sql`, `view.sql`, `agenda_email.py`, `syncTasksToDatabase.ty`).
   - Reorganizar o projeto para que a pasta principal seja a raiz do repositório Git, eliminando o nível aninhado `BeePlanner/BeePlanner`.

2. **Correção do Script `agenda_email.py`**:
   - Remover os blocos de redefinição com dados hardcoded e garantir a leitura exclusiva via `python-dotenv`.

3. **Correção de `seed_from_csv.py`**:
   - Alterar o caminho do arquivo para `data/raw/notion_metas_export.csv`.
   - Substituir a conexão `sqlite3` por `psycopg2` para salvar diretamente no banco PostgreSQL.

---

### 🏛 4.2. Melhorias na Arquitetura de Dados & SQL

1. **Padronização do Modelo de Dados (Estático vs. Dinâmico)**:
   - Adotar o **Modelo Dinâmico com Eixos** (`configuracao_roda` + `dim_eixos`), permitindo personalização da Roda da Vida (3 a 12 eixos).
   - Atualizar a view `vw_dashboard_final.sql` para realizar JOIN com `dim_eixos` em vez de `dim_subcategorias`.

2. **Criação de Script Unificado de Migração/Setup**:
   - Criar um script principal `database/init_db.sql` ou utilizar uma ferramenta de migração (ex: `Flyway` ou `Alembic`) para rodar os DDLs, Views e Seeds na ordem correta.

---

### 💻 4.3. Engenharia de Software & Qualidade de Código

1. **Centralização de Módulos Python**:
   - Criar um módulo `beeplanner/config.py` central para gerenciar configurações e conexões de banco de dados.
   - Consolidação dos scripts de calendário em um único módulo `beeplanner/services/calendar_service.py`.

2. **Criação de Testes Automatizados**:
   - Implementar testes unitários (com `pytest`) para verificar os cálculos de metas (75%, dias do ano e filtros de frequência) descritos no arquivo `docs/roteiro_testes_unitarios.md`.

---

### 🎨 4.4. Evolução da Interface de Usuário (Frontend & API)

1. **Construção de uma API REST (FastAPI)**:
   - Criar endpoints simples em Python FastAPI para expor:
     - `GET /api/dashboard`: dados calculados da view `vw_dashboard_final`.
     - `GET /api/metas`: listagem e CRUD de metas.
     - `POST /api/diario`: salvar ata diária no PostgreSQL.
2. **Integração do Frontend Demo**:
   - Atualizar o arquivo `beeplanner.js` para realizar chamadas `fetch()` aos endpoints da API FastAPI, tornando o dashboard 100% dinâmico e funcional.

---

## 5. Matriz de Priorização (Impacto vs. Esforço)

| Item | Ação | Severidade / Prioridade | Esforço | Impacto |
| :--- | :--- | :--- | :--- | :--- |
| **1** | Corrigir `agenda_email.py` (Remover credenciais hardcoded) | 🔴 Alta | ⏱ Baixo | ⚡ Alto |
| **2** | Remover arquivos duplicados da raiz | 🔴 Alta | ⏱ Baixo | ⚡ Médio |
| **3** | Unificar Schema SQL e corrigir `vw_dashboard_final.sql` | 🔴 Alta | ⏱ Médio | ⚡ Crítico |
| **4** | Refatorar `seed_from_csv.py` para PostgreSQL + CSV correto | 🔴 Alta | ⏱ Médio | ⚡ Alto |
| **5** | Consolidação dos scripts de calendário em módulo único | 🟡 Média | ⏱ Baixo | ⚡ Médio |
| **6** | Criar API FastAPI + integração do frontend web | 🟢 Baixa (Melhoria) | ⏱ Alto | ⚡ Alto |

---

## 6. Próximos Passos Sugeridos

1. **Aprovação do Plano**: Confirmar com a equipe/desenvolvedor a escolha do modelo de dados definitivo (Eixos Dinâmicos vs Subcategorias Fixas).
2. **Execução das Correções Críticas (Fase 1)**: Limpeza da raiz, correção do `agenda_email.py`, ajuste do DDL e carga dos dados iniciais.
3. **Validação**: Execução dos testes e verificação da sincronização via Google Apps Script.
