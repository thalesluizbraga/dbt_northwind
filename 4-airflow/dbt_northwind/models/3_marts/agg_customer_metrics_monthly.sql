with order_items as (

    select *
    from {{ ref('fct_order_items') }}

),

monthly as (

    select
        id_cliente,
        mes_pedido as mes_referencia,
        sum(receita_liquida) as receita_mes,
        count(distinct id_pedido) as qtd_pedidos_mes,
        count(*) as qtd_itens_mes,
        sum(quantidade) as qtd_unidades_mes,
        round(avg(receita_liquida), 2) as receita_media_item_mes,
        round(avg(case when tem_desconto then 1.0 else 0.0 end), 4) as taxa_itens_com_desconto_mes
    from order_items
    group by id_cliente, mes_pedido

),

final as (

    select
        id_cliente,
        mes_referencia,
        receita_mes,
        qtd_pedidos_mes,
        qtd_itens_mes,
        qtd_unidades_mes,
        round(receita_mes / nullif(qtd_pedidos_mes, 0), 2) as ticket_medio_mes,
        receita_media_item_mes,
        taxa_itens_com_desconto_mes
    from monthly

)

select *
from final
