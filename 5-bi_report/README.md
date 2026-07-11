# Análises Northwind — BI Report

Análises de ticket médio, desconto, cross-sell e produtos âncora usando as tabelas dbt (`fct_order_items`, `dim_categories`, etc.).

## Pré-requisitos

1. Postgres ativo: `cd ../2-local_setup && .\start-postgres.ps1`
2. Modelos dbt materializados: `cd ../3-dbt/dbt_northwind && .\run-dbt.ps1 run`

## Executar análises

```powershell
cd 5-bi_report
uv sync
uv run python run_analyses.py
```

## Estrutura

```text
5-bi_report/
├── sql/                    # Queries SQL (fonte das análises)
│   ├── 01_ticket_medio.sql
│   ├── 02_itens_por_pedido.sql
│   ├── 03_impacto_desconto.sql
│   ├── 04_cross_sell_categorias.sql
│   └── 05_produtos_ancora_expansao.sql
├── run_analyses.py         # Executa SQL + gera gráficos
└── output/                 # CSVs e PNGs gerados
```

## Análises

| # | Análise | Tabelas usadas | Saída |
|---|---------|----------------|-------|
| 1 | Ticket médio por pedido | `fct_order_items` | `01_ticket_medio_mensal.png` |
| 2 | Itens e unidades por pedido | `fct_order_items` | `02_itens_unidades_por_pedido.png` |
| 3 | Impacto do desconto | `fct_order_items` | `03_impacto_desconto.png` |
| 4 | Cross-sell de categorias | `fct_order_items`, `dim_categories` | `04_cross_sell_categorias.png` |
| 5 | Produtos âncora vs expansão | `fct_order_items` | `05_produtos_ancora_expansao.png` |

Cada análise também gera um `.csv` em `output/` com os dados tabulares.
