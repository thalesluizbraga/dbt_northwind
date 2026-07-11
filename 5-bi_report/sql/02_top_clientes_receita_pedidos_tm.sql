-- 6. Top 10 clientes por receita com representatividade no total da carteira
with pedidos_cliente as (
    select
        f.id_cliente,
        c.nome_empresa,
        f.id_pedido,
        sum(f.receita_liquida) as receita_pedido
    from public.fct_order_items as f
    left join public.dim_customers as c
        on f.id_cliente = c.id_cliente
    group by f.id_cliente, c.nome_empresa, f.id_pedido
),

resumo_cliente as (
    select
        id_cliente,
        coalesce(nome_empresa, 'Cliente sem nome') as nome_empresa,
        count(distinct id_pedido) as qtd_pedidos,
        round(sum(receita_pedido), 2) as receita_total,
        round(avg(receita_pedido), 2) as ticket_medio
    from pedidos_cliente
    group by id_cliente, coalesce(nome_empresa, 'Cliente sem nome')
),

top_10 as (
    select
        row_number() over (order by receita_total desc, qtd_pedidos desc) as ranking_receita,
        id_cliente,
        nome_empresa,
        qtd_pedidos,
        receita_total,
        ticket_medio,
        round(100.0 * receita_total / nullif(sum(receita_total) over (), 0), 2) as pct_receita_no_total,
        round(100.0 * qtd_pedidos / nullif(sum(qtd_pedidos) over (), 0), 2) as pct_pedidos_no_total
    from resumo_cliente
    order by receita_total desc, qtd_pedidos desc
    limit 10
)

select
    ranking_receita,
    id_cliente,
    nome_empresa,
    qtd_pedidos,
    receita_total,
    ticket_medio,
    pct_receita_no_total,
    pct_pedidos_no_total,
    round(sum(pct_receita_no_total) over (), 2) as pct_receita_top10_na_carteira,
    round(sum(pct_pedidos_no_total) over (), 2) as pct_pedidos_top10_no_total
from top_10
order by ranking_receita;
