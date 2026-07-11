-- 3. Impacto do desconto no ticket médio
with itens_pedido as (
    select
        id_pedido,
        mes_pedido,
        receita_liquida,
        tem_desconto,
        valor_desconto
    from public.fct_order_items
),

pedidos as (
    select
        id_pedido,
        mes_pedido,
        sum(receita_liquida) as receita_pedido,
        sum(valor_desconto) as desconto_total_pedido,
        bool_or(tem_desconto) as pedido_com_desconto
    from itens_pedido
    group by id_pedido, mes_pedido
)

select
    case when pedido_com_desconto then 'com_desconto' else 'sem_desconto' end as tipo_pedido,
    count(*) as qtd_pedidos,
    round(100.0 * count(*) / sum(count(*)) over (), 2) as pct_pedidos,
    round(avg(receita_pedido), 2) as ticket_medio,
    round(avg(desconto_total_pedido), 2) as desconto_medio,
    round(sum(receita_pedido), 2) as receita_total
from pedidos
group by pedido_com_desconto
order by tipo_pedido;
