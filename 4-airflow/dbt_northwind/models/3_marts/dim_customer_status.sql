with order_items as (

    select *
    from {{ ref('fct_order_items') }}

),

data_referencia as (

    select max(data_pedido)::date as data_referencia
    from order_items

),

customer_metrics as (

    select
        id_cliente,
        min(data_pedido)::date as data_primeiro_pedido,
        max(data_pedido)::date as data_ultimo_pedido,
        count(distinct id_pedido) as total_pedidos,
        sum(receita_liquida) as receita_total,
        round(avg(receita_liquida), 2) as receita_media_item,
        round(sum(receita_liquida) / nullif(count(distinct id_pedido), 0), 2) as ticket_medio,
        round(avg(case when tem_desconto then 1.0 else 0.0 end), 4) as taxa_itens_com_desconto
    from order_items
    group by id_cliente

),

final as (

    select
        c.id_cliente,
        c.data_primeiro_pedido,
        c.data_ultimo_pedido,
        c.total_pedidos,
        c.receita_total,
        c.receita_media_item,
        c.ticket_medio,
        c.taxa_itens_com_desconto,
        d.data_referencia,
        (d.data_referencia - c.data_ultimo_pedido) as dias_desde_ultimo_pedido,
        case
            when (d.data_referencia - c.data_ultimo_pedido) > 180 then 'churned'
            when (d.data_referencia - c.data_ultimo_pedido) > 90 then 'em_risco'
            else 'ativo'
        end as status_cliente
    from customer_metrics as c
    cross join data_referencia as d

)

select *
from final
