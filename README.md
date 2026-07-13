# dbt_northwind

Projeto de **Analytics Engineering** para a Northwind Traders: ingestão de dados do ERP, modelagem em camadas com **dbt**, orquestração opcional com **Airflow**, análises em **Jupyter** e sumário executivo em Word.

Repositório: [github.com/thalesluizbraga/dbt_northwind](https://github.com/thalesluizbraga/dbt_northwind)

---

## Pré-requisitos

Instale na máquina que irá rodar o projeto:

| Programa | Versão sugerida | Download |
|----------|-----------------|----------|
| **Git** | qualquer recente | [git-scm.com](https://git-scm.com/) |
| **Docker Desktop** | latest | [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/) |
| **Python** | 3.12+ | [python.org](https://www.python.org/downloads/) |
| **uv** (gerenciador de pacotes) | latest | [docs.astral.sh/uv](https://docs.astral.sh/uv/getting-started/installation/) |

Opcionais:

| Programa | Uso |
|----------|-----|
| **VS Code / Cursor** | Editar código, notebook e SQL |
| **Power BI Desktop** | Conectar às tabelas `dim_*` / `fct_*` |
| **Astronomer CLI** | Orquestração local com Airflow (`4-airflow/`) |

---

## Como rodar o projeto (do zero)

### 1. Clonar o repositório

```bash
git clone https://github.com/thalesluizbraga/dbt_northwind.git
cd dbt_northwind
```

### 2. Subir o PostgreSQL (Docker)

Abra o **Docker Desktop** e aguarde iniciar.

**PowerShell:**

```powershell
cd 2-local_setup
.\start-postgres.ps1
```

**Git Bash:**

```bash
cd 2-local_setup
./start-postgres.sh
```

Verificar:

```bash
docker compose ps
docker exec dbt_postgres pg_isready -U postgres -d dbt_db
```

Conexão do banco:

| Campo | Valor |
|-------|-------|
| Host | `localhost` |
| Porta | `5433` |
| Banco | `dbt_db` |
| Usuário / Senha | `postgres` / `postgres` |

### 3. Ambiente Python e carga dos CSVs

```bash
cd 2-local_setup
uv sync
uv run python -m etl.load_raw
```

Isso lê os arquivos em `1-data/` e grava no schema **`raw`** do Postgres.

### 4. Rodar o dbt (transformações)

```powershell
cd ..\3-dbt\dbt_northwind
.\run-dbt.ps1 debug
.\run-dbt.ps1 run
.\run-dbt.ps1 test
```

**Git Bash:**

```bash
cd ../3-dbt/dbt_northwind
./run-dbt.sh debug
./run-dbt.sh run
./run-dbt.sh test
```

> Documentação interativa dos modelos: ver seção [**Documentação dbt (dbt docs)**](#documentação-dbt-dbt-docs) abaixo.

### 5. Rodar as análises (Jupyter)

```bash
cd ../../2-local_setup
uv run python -m ipykernel install --user --name northwind-local --display-name "Python 3 (2-local_setup)"
```

Abra `5-bi_report/northwind_analyses.ipynb` no Cursor/VS Code e:

1. Selecione o kernel **`Python 3 (2-local_setup)`**
2. Execute a célula de setup (imports + conexão)
3. Execute as demais células em ordem

As saídas (CSV e PNG) são gravadas em `5-bi_report/output/`.

### 6. Gerar o sumário executivo (Word)

```powershell
cd ..
.\2-local_setup\.venv\Scripts\python.exe .\docs\gerar_sumario_executivo.py
```

Arquivo gerado: `Sumario_Executivo_Northwind.docx`

### 7. Airflow (opcional)

Requer [Astronomer CLI](https://docs.astronomer.io/astro/cli/install-cli) e Postgres já rodando.

```bash
cd 2-local_setup && docker compose up -d
cd ../4-airflow
cp airflow_settings.yaml.example airflow_settings.yaml   # 1ª vez
astro dev start
```

- UI: http://localhost:8080 (`admin` / `admin`)
- DAG: `northwind_pipeline`

---

## Estrutura do projeto

```text
dbt_northwind/
├── 1-data/                 # CSVs brutos do ERP Northwind
├── 2-local_setup/          # Docker Postgres, ETL Python, .env, ambiente uv
├── 3-dbt/dbt_northwind/    # Projeto dbt (fonte da verdade dos modelos)
├── 4-airflow/              # Orquestração Astro + espelho dbt para Cosmos
├── 5-bi_report/            # SQLs, notebook Jupyter e outputs analíticos
├── docs/                   # Diagrama de arquitetura e script do sumário
├── Sumario_Executivo_Northwind.docx
└── README.md
```

### Camadas de dados

```text
1-data (CSV)
    ↓  Python ETL (load_raw.py)
PostgreSQL — schema raw (raw_orders, raw_customers, ...)
    ↓  dbt — staging
stg_northwind__*  (limpeza, tipagem, renomeação)
    ↓  dbt — intermediate
int_*  (joins e lógica de negócio reutilizável)
    ↓  dbt — marts
dim_*   dimensões (clientes, produtos, categorias, ...)
fct_*   fatos (fct_order_items — grão item de pedido)
agg_*   agregados mensais (cliente, região, funcionário)
    ↓
5-bi_report / Power BI / Sumário Executivo
```

| Camada | Prefixo | Exemplos |
|--------|---------|----------|
| Staging | `stg_northwind__` | `stg_northwind__customers`, `stg_northwind__orders` |
| Intermediate | `int_` | `int_order_items` |
| Marts — dimensão | `dim_` | `dim_customers`, `dim_products`, `dim_customer_status` |
| Marts — fato | `fct_` | `fct_order_items` |
| Marts — agregado | `agg_` | `agg_customer_metrics_monthly`, `agg_region_revenue_monthly` |

---

## Documentação dbt (dbt docs)

Site interativo com **linhagem**, descrições dos modelos, colunas, testes e SQL compilado. Útil para entender como os dados fluem do `raw` até os marts usados no BI.

### Portas locais (evitar conflito com Airflow)

| Serviço | URL | Porta padrão neste projeto |
|---------|-----|----------------------------|
| **Airflow** (opcional) | http://localhost:8080 | `8080` |
| **dbt docs** | http://localhost:8081 | `8081` |

O `dbt docs serve` usa **8080 por padrão** — a mesma do Airflow. Os scripts `run-dbt.ps1` / `run-dbt.sh` deste repositório sobem a documentação automaticamente na **8081** (variável `DBT_DOCS_PORT` no `.env`, se quiser outra porta).

**Pré-requisitos:** Postgres ativo e pelo menos um `dbt run` concluído (para gerar o `manifest.json`).

### Comandos

Sempre dentro de `3-dbt/dbt_northwind/`.

**Gerar + servir (recomendado):**

```powershell
cd 3-dbt\dbt_northwind
.\run-dbt-docs.ps1
```

```bash
cd 3-dbt/dbt_northwind
./run-dbt-docs.sh
```

Abra no navegador: **http://localhost:8081** (Ctrl+C no terminal para encerrar).

**Passo a passo (gerar e servir separadamente):**

```powershell
.\run-dbt.ps1 docs generate    # gera target/manifest.json e target/catalog.json
.\run-dbt.ps1 docs serve       # sobe o site na porta 8081
```

```bash
./run-dbt.sh docs generate
./run-dbt.sh docs serve
```

**Outra porta (ex.: 8090):**

```powershell
.\run-dbt.ps1 docs serve --port 8090
```

Ou defina no `2-local_setup/.env`:

```env
DBT_DOCS_PORT=8090
```

### O que você pode ver na interface

**1. Overview do projeto**  
Lista de todos os modelos organizados por pasta (`1_staging`, `2_intermediate`, `3_marts`).

**2. Grafo de linhagem (Lineage)**  
Diagrama interativo mostrando dependências entre tabelas. Exemplo de fluxo:

```text
source:northwind.raw_order_details
    → stg_northwind__order_details
    → int_order_items
    → fct_order_items
         ↘ dim_customer_status
         ↘ agg_customer_metrics_monthly
```

Clique em um nó para ver detalhes; use o filtro para isolar um modelo (ex.: `fct_order_items`).

**3. Página de cada modelo**  
Ao abrir um modelo, você vê:

| O que aparece | Exemplo neste projeto |
|---------------|----------------------|
| Descrição do modelo | `fct_order_items` — *"Fato no grão item de pedido com métricas de receita e entrega."* |
| Colunas documentadas | `receita_liquida`, `valor_desconto`, `tem_desconto`, `regiao_entrega` |
| Testes de qualidade | `not_null` em `id_pedido`; `accepted_values` em `status_cliente` (`ativo`, `em_risco`, `churned`) |
| SQL compilado | Query final enviada ao Postgres (aba **Code**) |
| Dependências upstream/downstream | Quais modelos alimentam e são alimentados por aquele modelo |

**4. Sources (fontes raw)**  
Tabelas do schema `raw` carregadas pelo ETL, com descrição de origem:

- `raw_orders` ← `orders.csv`
- `raw_order_details` ← `order_details.csv`
- `raw_customers` ← `customers.csv`

**5. Column lineage**  
Na página de um modelo, rastreie uma coluna (ex.: `receita_liquida`) até os campos de origem em staging e raw.

**6. Testes**  
Visão dos testes configurados em `src_northwind.yml` e `marts.yml` (`unique`, `not_null`, `accepted_values`) e status após `dbt test`.

> Mais detalhes dos wrappers dbt: `3-dbt/dbt_northwind/README.md`

---

## Análises disponíveis

Notebook: `5-bi_report/northwind_analyses.ipynb`  
Saídas: CSV e PNG em `5-bi_report/output/`

### 1 — Visão geral

| # | Análise | SQL | Objetivo de negócio |
|---|---------|-----|---------------------|
| 1.1 | Receita mensal | `01_receita_e_qtd_pedidos_mensal.sql` | Evolução de receita e volume de pedidos |
| 1.2 | Top 10 clientes | `02_top_clientes_receita_pedidos_tm.sql` | Concentração da carteira (receita, pedidos e ticket) |

### 2 — Aumento de ticket médio (TM)

| # | Análise | SQL | Objetivo de negócio |
|---|---------|-----|---------------------|
| 2.1 | Categoria × região | `03_top_categoria_regiao_ticket_medio.sql` | Combinações com maior ticket médio |
| 2.2 | Cross-sell | `04_cross_sell_categorias.sql` | Pares de categorias comprados no mesmo pedido |
| 2.3 | Âncora vs expansão | `05_produtos_ancora_expansao.sql` | Aquisição (1º pedido) vs monetização do relacionamento |
| 2.4 | Impacto do desconto | `09_impacto_desconto.sql` | Verificar se descontos comprimem ticket ou estimulam volume |

### 3 — Redução de churn

| # | Análise | SQL | Objetivo de negócio |
|---|---------|-----|---------------------|
| 3.1 | Churn trimestral (90 dias) | `06_churn_trimestral.sql` | Evolução de ativos, novos e churn por trimestre |
| 3.2 | Clientes em declínio | `07_clientes_em_declinio.sql` | Early warning com base na periodicidade entre compras |
| 3.3 | Perfil churn vs ativos | `08_perfil_churn_vs_ativos.sql` | Perfil geográfico e comportamental dos clientes em risco |

---

## Glossário de métricas

Definições adotadas no notebook `northwind_analyses.ipynb` e no `Sumario_Executivo_Northwind.docx`.

### Métricas base (camada `fct_order_items`)

| Métrica | Fórmula / definição |
|---------|---------------------|
| **Receita bruta** | `preco_unitario × quantidade` |
| **Valor desconto** | `preco_unitario × quantidade × desconto` |
| **Receita líquida** | `preco_unitario × quantidade × (1 - desconto)` |
| **Tem desconto** | `desconto > 0` no item |
| **Entrega atrasada** | `data_envio > data_requerida` |
| **Dias para envio** | `data_envio - data_pedido` (em dias) |

### Ticket médio e receita

| Métrica | Fórmula / definição |
|---------|---------------------|
| **Ticket médio (pedido)** | `soma(receita_liquida do pedido) / 1 pedido` — valor médio por pedido |
| **Ticket médio (cliente)** | `receita_total do cliente / total de pedidos do cliente` |
| **Receita mensal** | Soma de `receita_liquida` no mês (`mes_referencia`) |
| **Qtd pedidos no mês** | `count(distinct id_pedido)` no mês |
| **% receita no total** | `100 × receita_cliente / receita_total_carteira` |
| **% pedidos no total** | `100 × pedidos_cliente / pedidos_total_carteira` |

### Desconto e impacto no ticket (análise 2.4)

Classificação e resumo no **nível do pedido** (`09_impacto_desconto.sql`):

| Métrica | Fórmula / definição |
|---------|---------------------|
| **Pedido com desconto** | Pedido com ao menos um item onde `desconto > 0` |
| **Pedido sem desconto** | Pedido em que nenhum item tem `desconto > 0` |
| **Ticket do pedido** | `sum(receita_liquida)` de todos os itens do `id_pedido` |
| **Ticket médio com desconto** | Média do ticket apenas entre pedidos com desconto |
| **Ticket médio sem desconto** | Média do ticket apenas entre pedidos sem desconto |
| **% pedidos com desconto** | `100 × qtd_pedidos_com_desconto / total_pedidos` |
| **Desconto médio por pedido** | Média de `sum(valor_desconto)` do pedido, apenas entre pedidos com desconto |
| **Receita total por tipo** | Soma do ticket dos pedidos com ou sem desconto |

Breakdown dimensional no **nível do item** (categoria, funcionário, região):

| Métrica | Fórmula / definição |
|---------|---------------------|
| **Desconto médio (R$)** | Média de `valor_desconto` nos itens com `desconto > 0` da dimensão |
| **Desconto médio % (taxa)** | Média do campo `desconto` (0–1) nos itens com desconto da dimensão |
| **% itens com desconto** | `100 × itens_com_desconto / total_itens` na dimensão |
| **Ticket médio por item** | Média de `receita_liquida` por linha na dimensão (não confundir com ticket do pedido) |

**Interpretação (2.4):**

- Se **ticket médio com desconto > ticket médio sem desconto** → desconto associado a pedidos maiores (estímulo de volume).
- Se **ticket médio com desconto < ticket médio sem desconto** → desconto associado a pedidos menores (possível compressão de ticket).

**Tabelas usadas:** `fct_order_items`, `dim_categories`, `dim_employees`  
**Saídas:** `09_impacto_desconto.csv`, `09_impacto_desconto.png`, `09_impacto_desconto_funcionarios.png`

### Cross-sell e categoria × região

| Métrica | Fórmula / definição |
|---------|---------------------|
| **Par de categorias** | Duas categorias distintas no mesmo `id_pedido` |
| **Qtd pedidos com par** | Pedidos em que o par de categorias aparece junto |
| **Ticket médio do par** | Receita média dos pedidos que contêm aquele par |
| **Ticket médio categoria × região** | Receita do par categoria+região no pedido, média por pedido |

### Produtos âncora vs expansão

| Métrica | Fórmula / definição |
|---------|---------------------|
| **Produto âncora** | Item comprado no **primeiro pedido** do cliente |
| **Produto de expansão** | Item comprado em **pedidos subsequentes** |
| **Receita total por tipo** | Soma de `receita_liquida` de todos os itens classificados como âncora ou expansão |
| **Receita média por item** | `receita_total / qtd_linhas` do produto naquele tipo |

### Churn e retenção

| Métrica | Fórmula / definição |
|---------|---------------------|
| **Churn (operacional)** | Cliente sem pedido há mais de **180 dias** (`dim_customer_status`) |
| **Em risco** | Sem pedido há mais de **90 dias** e até 180 dias |
| **Ativo** | Pedido nos últimos 90 dias |
| **Dias desde último pedido** | `data_referencia - data_ultimo_pedido` (referência = última data do dataset) |
| **Churn trimestral (90 dias)** | Cliente com último pedido há **mais de 90 dias** na data de fechamento do trimestre |
| **Início da análise trimestral** | Primeiro mês de dados + 90 dias (ex.: jan → 1ª medição em mar) |
| **Clientes carteira** | Clientes com ao menos um pedido até o fim do trimestre |
| **Clientes mantidos ativos** | Ativos no fim do trimestre que já estavam ativos no trimestre anterior |
| **Clientes novos no trimestre** | Primeira compra ocorreu dentro do trimestre e seguem ativos (≤ 90 dias) |
| **Clientes reativados** | Voltaram a comprar no trimestre após período inativo (incluídos em "mantidos" no gráfico) |
| **Taxa de churn trimestral** | `100 × clientes_churn / clientes_carteira` no fim do trimestre |
| **Taxa de ativos trimestral** | `100 × clientes_ativos / clientes_carteira` (último pedido ≤ 90 dias) |
| **Intervalo médio entre pedidos** | Média de dias entre pedidos consecutivos do cliente |
| **Periodicidade média global** | Média dos intervalos médios de todos os clientes com 2+ pedidos |
| **Potencial churn** | `dias_desde_ultimo_pedido > intervalo_medio_dias` do cliente (ou da média global, se 1 pedido) |
| **Razão atraso vs média** | `dias_desde_ultimo_pedido / intervalo_medio_dias` |
| **% no grupo (perfil geográfico)** | Distribuição de clientes churn ou ativos por país, região ou cidade |

### Status do cliente (`dim_customer_status`)

| Campo | Descrição |
|-------|-----------|
| `data_primeiro_pedido` | Data do 1º pedido |
| `data_ultimo_pedido` | Data do último pedido |
| `total_pedidos` | Pedidos distintos do cliente |
| `receita_total` | Soma de receita líquida |
| `ticket_medio` | Receita total / total de pedidos |
| `taxa_itens_com_desconto` | % de linhas com desconto |
| `status_cliente` | `ativo`, `em_risco` ou `churned` |

---

## Troubleshooting

| Problema | Solução |
|----------|---------|
| `docker: command not found` | Instale e abra o Docker Desktop |
| Porta 5433 em uso | Pare o serviço conflitante ou altere `DBT_PORT` no `.env` |
| `git add .` não adiciona arquivos | Rode `git add .` na **raiz** do repositório (`dbt_northwind/`), não em subpastas como `2-local_setup/`. De dentro de qualquer pasta, use `git add -A` para incluir tudo |
| `git add .` falha (SQLTools) | Remova `con.session.sql` (arquivo temporário do SQLTools) — já está no `.gitignore` |
| Notebook sem gráfico | Execute a célula de setup primeiro; confirme kernel `Python 3 (2-local_setup)` |
| SQL não encontrado no notebook | Confira `5-bi_report/sql/` — churn usa `06_`–`08_`; desconto usa `09_impacto_desconto.sql` |
| Tabelas vazias | Rode `uv run python -m etl.load_raw` e depois `.\run-dbt.ps1 run` |

---

## Documentação adicional

| Pasta | Conteúdo |
|-------|----------|
| `2-local_setup/README.md` | Postgres, ETL e conexão |
| `3-dbt/dbt_northwind/README.md` | Comandos dbt e camadas |
| `4-airflow/README.md` | Astro e DAG Cosmos |
| `5-bi_report/README.md` | Análises BI |
| `docs/SETUP.md` | Documentação detalhada do monorepo |

---

## Licença e contexto

Projeto desenvolvido no contexto do desafio **Analista de Dados / Engenheiro de Analytics** (Northwind Traders / Indicium), com foco em aumento de ticket médio, redução de churn e visão integrada dos dados.
