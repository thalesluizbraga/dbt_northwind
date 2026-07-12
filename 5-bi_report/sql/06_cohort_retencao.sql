-- 8. Curva de retenção por coorte (sugestão 2.2)
-- Coorte = mês do primeiro pedido; retenção = % que voltou a comprar no mês N após o 1º pedido
with pedidos_distintos as (
    select distinct
        id_cliente,
        data_pedido::date as data_pedido
    from public.fct_order_items
),

primeiro_pedido as (
    select
        id_cliente,
        min(data_pedido) as data_primeiro_pedido,
        date_trunc('month', min(data_pedido))::date as mes_cohort
    from pedidos_distintos
    group by id_cliente
),

atividade_mensal as (
    select distinct
        p.id_cliente,
        fp.mes_cohort,
        date_trunc('month', p.data_pedido)::date as mes_atividade
    from pedidos_distintos as p
    inner join primeiro_pedido as fp
        on p.id_cliente = fp.id_cliente
),

cohort_periodos as (
    select
        mes_cohort,
        id_cliente,
        mes_atividade,
        (
            (extract(year from age(mes_atividade, mes_cohort)) * 12)
            + extract(month from age(mes_atividade, mes_cohort))
        )::int as meses_desde_cohort
    from atividade_mensal
),

cohort_sizes as (
    select
        mes_cohort,
        count(*) as tamanho_cohort
    from primeiro_pedido
    group by mes_cohort
),

retencao as (
    select
        cp.mes_cohort,
        cp.meses_desde_cohort,
        cs.tamanho_cohort,
        count(distinct cp.id_cliente) as clientes_ativos
    from cohort_periodos as cp
    inner join cohort_sizes as cs
        on cp.mes_cohort = cs.mes_cohort
    where cp.meses_desde_cohort >= 0
    group by cp.mes_cohort, cp.meses_desde_cohort, cs.tamanho_cohort
)

select
    mes_cohort,
    meses_desde_cohort,
    tamanho_cohort,
    clientes_ativos,
    round(100.0 * clientes_ativos / nullif(tamanho_cohort, 0), 2) as taxa_retencao_pct
from retencao
order by mes_cohort, meses_desde_cohort;
