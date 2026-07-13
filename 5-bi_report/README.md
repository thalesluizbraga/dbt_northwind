# Análises Northwind — BI Report

Análises de receita, ticket médio, desconto, cross-sell, produtos âncora e churn usando as tabelas dbt (`fct_order_items`, `dim_categories`, `dim_employees`, `dim_customers`, etc.).

## Pré-requisitos

1. Postgres ativo: `cd ../2-local_setup && .\start-postgres.ps1`
2. Modelos dbt materializados: `cd ../3-dbt/dbt_northwind && .\run-dbt.ps1 run`

## Executar análises

Abra `northwind_analyses.ipynb` no Cursor/VS Code:

1. Kernel **`Python 3 (2-local_setup)`**
2. Execute a célula de setup
3. Execute as células em ordem (1.1 → 3.3)

As saídas (CSV e PNG) são gravadas em `output/`.

## Estrutura

```text
5-bi_report/
├── sql/                         # Queries SQL (fonte das análises)
│   ├── 01_receita_e_qtd_pedidos_mensal.sql
│   ├── 02_top_clientes_receita_pedidos_tm.sql
│   ├── 03_top_categoria_regiao_ticket_medio.sql
│   ├── 04_cross_sell_categorias.sql
│   ├── 05_produtos_ancora_expansao.sql
│   ├── 06_churn_trimestral.sql
│   ├── 07_clientes_em_declinio.sql
│   ├── 08_perfil_churn_vs_ativos.sql
│   └── 09_impacto_desconto.sql
├── northwind_analyses.ipynb     # Notebook principal
└── output/                      # CSVs e PNGs gerados
```

## Análises

| Seção | # | Análise | SQL | Saída principal |
|-------|---|---------|-----|-----------------|
| Visão geral | 1.1 | Receita mensal | `01_...` | `01_receita_mensal.png` |
| Visão geral | 1.2 | Top 10 clientes | `02_...` | `02_top_clientes.csv` |
| Aumento TM | 2.1 | Categoria × região | `03_...` | `07_top_categoria_regiao_ticket_medio.csv` |
| Aumento TM | 2.2 | Cross-sell | `04_...` | `04_cross_sell_categorias.png` |
| Aumento TM | 2.3 | Âncora vs expansão | `05_...` | `05_produtos_ancora_expansao.png` |
| Aumento TM | 2.4 | Impacto do desconto | `09_...` | `09_impacto_desconto.png` |
| Churn | 3.1 | Churn trimestral | `06_...` | `06_churn_trimestral.png` |
| Churn | 3.2 | Clientes em declínio | `07_...` | `07_clientes_em_declinio.png` |
| Churn | 3.3 | Perfil churn vs ativos | `08_...` | `08_perfil_churn_vs_ativos.png` |

Glossário completo de métricas: ver `../README.md` (seção **Glossário de métricas**).
