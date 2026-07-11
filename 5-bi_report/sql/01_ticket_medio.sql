-- 1. Ticket médio por pedido (visão geral + evolução mensal)
with pedidos as (
    select
        id_pedido,
        mes_pedido,
        sum(receita_liquida) as receita_pedido
    from public.fct_order_items
    group by id_pedido, mes_pedido
)

select
    'geral' as nivel,
    null::date as mes_pedido,
    count(distinct id_pedido) as qtd_pedidos,
    round(avg(receita_pedido), 2) as ticket_medio,
    round(min(receita_pedido), 2) as ticket_minimo,
    round(max(receita_pedido), 2) as ticket_maximo,
    round(sum(receita_pedido), 2) as receita_total
from pedidos

union all

select
    'mensal' as nivel,
    mes_pedido,
    count(distinct id_pedido) as qtd_pedidos,
    round(avg(receita_pedido), 2) as ticket_medio,
    round(min(receita_pedido), 2) as ticket_minimo,
    round(max(receita_pedido), 2) as ticket_maximo,
    round(sum(receita_pedido), 2) as receita_total
from pedidos
group by mes_pedido
order by nivel, mes_pedido;
