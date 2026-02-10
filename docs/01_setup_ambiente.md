# 🛠️ Setup de Ambiente - BeePlanner 1.0

Este guia descreve os passos para configurar o ambiente de desenvolvimento local para o motor de engenharia de dados do BeePlanner.

## 1. Pré-requisitos
Certifique-se de ter instalado:
- **Python 3.10+**: [Download](https://www.python.org/downloads/)
- **PostgreSQL 15+**: [Download](https://www.postgresql.org/download/)
- **Git**: [Download](https://git-scm.com/)
- **VS Code** (ou IDE de preferência).

## 2. Estrutura de Diretórios
Crie a seguinte árvore de pastas para organizar o projeto:

```bash
beeplanner/
├── database/
│   ├── ddl/          # Scripts CREATE TABLE
│   ├── seeds/        # Scripts INSERT (Dados estáticos)
│   └── views/        # Scripts CREATE VIEW
├── scripts/
│   ├── python/       # Scripts de cálculo (Calendar/Metas)
│   └── apps_script/  # Scripts .gs para Google
├── data/
│   ├── raw/          # CSVs originais do Notion
│   └── processed/    # CSVs gerados pelos scripts Python
└── tests/            # Testes unitários
```

## 3. Ambiente Virtual Python (Virtualenv)
Isolamento das dependências do projeto.

```bash
# Windows
python -m venv venv
.\venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

## 4. Instalação de Dependências
Crie um arquivo requirements.txt na raiz e instale:

```bash
pandas
psycopg2-binary
pytest
```

Execute:

```bash
pip install -r requirements.txt
```

## 5. Configuração do Google Cloud (Opcional para Fase 1)
Para o script de sincronização (google_tasks_sync.gs):

1. Acesse script.google.com.
2. Habilite o serviço Tasks API no menu de Serviços.
