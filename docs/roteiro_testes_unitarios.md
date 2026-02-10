# 🧪 Roteiro de Testes Unitários - BeePlanner 1.0

Antes de prosseguir para a versão 2.0, devemos validar a integridade dos dados e a lógica de cálculo.

## Escopo dos Testes
1. Geração de Calendário (Python)
2. Cálculo de Metas 2026 (Python)
3. Integridade do Banco de Dados (SQL)

---

## 1. Testes Unitários Python (`tests/test_logic.py`)
Criar um script usando `unittest` para validar as funções principais.

### Caso de Teste 1.1: Ano Bissexto
- **Entrada:** Gerar calendário para 2028.
- **Expectativa:** O DataFrame deve conter 366 linhas. O dia 29/02/2028 deve existir.

### Caso de Teste 1.2: Mapeamento de Dias da Semana
- **Entrada:** Data `2026-01-01` (Quinta-feira).
- **Expectativa:** O campo `dia_semana` deve corresponder a 4 (Quinta) e `is_fim_semana` deve ser False.

### Caso de Teste 1.3: Cálculo de Meta Semanal (Terça/Quinta)
- **Cenário:** Ano 2026 começa numa Quinta e termina numa Quinta.
- **Cálculo Manual:** 52 semanas * 2 = 104. +1 Quinta extra no dia 31/12. Total = 105.
- **Expectativa:** A função deve retornar **105 dias** para a frequência "Terça, Quinta".
- **Validação de 75%:** 105 * 0.75 = 78.75 -> Round -> **79 dias**.

---

## 2. Testes de Integração SQL (Manual ou Pytest)

### Caso de Teste 2.1: Constraint de Unicidade
- **Ação:** Tentar inserir duas vezes a mesma meta (ID 1) na mesma data (`2026-01-01`) na tabela `fact_execucoes`.
- **Expectativa:** O banco deve retornar erro `duplicate key value violates unique constraint`.
- **Por que:** Evita que um erro no script do Google Tasks duplique suas métricas.

### Caso de Teste 2.2: Validação da View de Dashboard
- **Configuração:**
  - Meta: Ler Bíblia (Alvo 75% = 274 dias).
  - Inserir 274 registros na `fact_execucoes`.
- **Query:** `SELECT status FROM vw_dashboard_final WHERE titulo = 'Ler Bíblia'`
- **Expectativa:** Retornar `'META BATIDA'`.
- **Ação:** Deletar 1 registro (Total 273).
- **Expectativa:** Retornar `'EM PROGRESSO'`.

---

## 3. Checklist de Execução
- [ ] Rodar script `generate_calendar.py` e validar CSV.
- [ ] Rodar `setup_banco.md` e verificar criação de tabelas.
- [ ] Importar CSV de calendário para `dim_calendario`.
- [ ] Rodar `test_logic.py` (criação pendente) e obter **OK**.
- [ ] Tentar inserção duplicada no SQL e confirmar bloqueio.