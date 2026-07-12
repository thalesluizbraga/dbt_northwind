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

Documentação interativa do dbt: **http://localhost:8081** (`.\run-dbt-docs.ps1`)

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

## Análises disponíveis

Notebook: `5-bi_report/northwind_analyses.ipynb`

| # | Análise | SQL | Objetivo de negócio |
|---|---------|-----|---------------------|
| 1.1 | Receita mensal | `01_receita_e_qtd_pedidos_mensal.sql` | Evolução de receita e volume |
| 1.2 | Top 10 clientes | `02_top_clientes_receita_pedidos_tm.sql` | Concentração da carteira |
| 1.3 | Categoria × região | `03_top_categoria_regiao_ticket_medio.sql` | Oportunidades regionais de ticket |
| 2.1 | Cross-sell | `04_cross_sell_categorias.sql` | Pares de categorias no mesmo pedido |
| 2.2 | Âncora vs expansão | `05_produtos_ancora_expansao.sql` | Aquisição vs monetização do relacionamento |
| 3.1 | Coorte de retenção | `06_cohort_retencao.sql` | Quando clientes param de voltar |
| 3.2 | Clientes em declínio | `07_clientes_em_declinio.sql` | Early warning de churn |
| 3.3 | Perfil churn vs ativos | `08_perfil_churn_vs_ativos.sql` | Onde estão os clientes em risco |

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

### Desconto

| Métrica | Fórmula / definição |
|---------|---------------------|
| **Pedido com desconto** | Pedido com ao menos um item onde `desconto > 0` |
| **Ticket médio com desconto** | Média do valor do pedido apenas entre pedidos com desconto |
| **Ticket médio sem desconto** | Média do valor do pedido apenas entre pedidos sem desconto |
| **% pedidos com desconto** | Proporção de pedidos que tiveram desconto |

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
| **Coorte** | Mês do **primeiro pedido** do cliente |
| **Meses desde coorte** | Meses calendário entre o mês da coorte e o mês da atividade |
| **Taxa de retenção** | `100 × clientes_ativos_no_mês_N / tamanho_da_coorte` |
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
| `git add .` falha | Remova `con.session.sql` (arquivo temporário do SQLTools) — já está no `.gitignore` |
| Notebook sem gráfico | Execute a célula de setup primeiro; confirme kernel `Python 3 (2-local_setup)` |
| SQL não encontrado no notebook | Use os arquivos `06_`, `07_`, `08_` para análises de churn |
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
