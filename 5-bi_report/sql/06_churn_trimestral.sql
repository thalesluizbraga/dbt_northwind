-- 6. Churn trimestral (90 dias sem comprar)
-- Positivo: mantidos ativos + novos no trimestre | Negativo: churn (> 90 dias inativos)
with pedidos as (
    select distinct
        id_cliente,
        data_pedido::date as data_pedido
    from public.fct_order_items
    where 
    1=1
     and mes_pedido < '1998-04-01'
),

primeiro_pedido as (
    select
        id_cliente,
        min(data_pedido) as data_primeiro_pedido
    from pedidos
    group by id_cliente
),

limites as (
    select
        min(data_pedido) as data_inicio,
        date_trunc('month', min(data_pedido))::date as mes_inicio,
        max(data_pedido) as data_fim,
        (date_trunc('month', min(data_pedido))::date + interval '90 days')::date as primeira_data_analise
    from pedidos
),

trimestres as (
    select
        gs::date as trimestre_inicio,
        (gs + interval '3 months' - interval '1 day')::date as data_referencia,
        to_char(gs, 'YYYY') || '-Q' || extract(quarter from gs)::int as trimestre_label
    from limites as l
    cross join lateral generate_series(
        date_trunc('quarter', l.primeira_data_analise::timestamp),
        date_trunc('quarter', l.data_fim::timestamp),
        interval '3 months'
    ) as gs
    where (gs + interval '3 months' - interval '1 day')::date >= l.primeira_data_analise
),

clientes_por_trimestre as (
    select
        t.trimestre_inicio,
        t.trimestre_label,
        t.data_referencia,
        p.id_cliente,
        pp.data_primeiro_pedido,
        max(p.data_pedido) as data_ultimo_pedido
    from trimestres as t
    inner join pedidos as p
        on p.data_pedido <= t.data_referencia
    inner join primeiro_pedido as pp
        on p.id_cliente = pp.id_cliente
    group by
        t.trimestre_inicio,
        t.trimestre_label,
        t.data_referencia,
        p.id_cliente,
        pp.data_primeiro_pedido
),

com_status as (
    select
        trimestre_inicio,
        trimestre_label,
        data_referencia,
        id_cliente,
        data_primeiro_pedido,
        data_ultimo_pedido,
        (data_referencia - data_ultimo_pedido) <= 90 as ativo,
        data_primeiro_pedido >= trimestre_inicio
            and data_primeiro_pedido <= data_referencia as novo_no_trimestre
    from clientes_por_trimestre
),

com_lag as (
    select
        *,
        lag(ativo) over (
            partition by id_cliente
            order by trimestre_inicio
        ) as ativo_trimestre_anterior
    from com_status
),

metricas as (
    select
        trimestre_inicio,
        trimestre_label,
        data_referencia,
        count(*) as clientes_carteira,
        count(*) filter (
            where ativo
                and not novo_no_trimestre
                and coalesce(ativo_trimestre_anterior, false)
        ) as clientes_mantidos_ativos,
        count(*) filter (
            where ativo and novo_no_trimestre
        ) as clientes_novos,
        count(*) filter (
            where ativo
                and not novo_no_trimestre
                and not coalesce(ativo_trimestre_anterior, false)
        ) as clientes_reativados,
        count(*) filter (
            where not ativo
        ) as clientes_churn,
        count(*) filter (where ativo) as clientes_ativos
    from com_lag
    group by trimestre_inicio, trimestre_label, data_referencia
)

select
    trimestre_inicio,
    trimestre_label,
    data_referencia,
    clientes_carteira,
    clientes_mantidos_ativos,
    clientes_novos,
    clientes_reativados,
    clientes_ativos,
    clientes_churn,
    round(100.0 * clientes_churn / nullif(clientes_carteira, 0), 2) as taxa_churn_pct,
    round(100.0 * clientes_ativos / nullif(clientes_carteira, 0), 2) as taxa_ativos_pct
from metricas
order by trimestre_inicio;
