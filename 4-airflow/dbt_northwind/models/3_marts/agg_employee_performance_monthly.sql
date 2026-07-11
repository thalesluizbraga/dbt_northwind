with order_items as (

    select *
    from {{ ref('fct_order_items') }}

),

monthly as (

    select
        id_funcionario,
        mes_pedido as mes_referencia,
        sum(receita_liquida) as receita_total,
        count(distinct id_pedido) as qtd_pedidos,
        count(distinct id_cliente) as qtd_clientes,
        count(*) as qtd_itens,
        round(sum(receita_liquida) / nullif(count(distinct id_pedido), 0), 2) as ticket_medio,
        round(avg(receita_liquida), 2) as receita_media_item,
        round(avg(case when tem_desconto then 1.0 else 0.0 end), 4) as taxa_itens_com_desconto,
        round(avg(case when entrega_atrasada then 1.0 else 0.0 end), 4) as taxa_entregas_atrasadas
    from order_items
    group by id_funcionario, mes_pedido

),

final as (

    select
        id_funcionario,
        mes_referencia,
        receita_total,
        qtd_pedidos,
        qtd_clientes,
        qtd_itens,
        ticket_medio,
        receita_media_item,
        taxa_itens_com_desconto,
        taxa_entregas_atrasadas,
        rank() over (
            partition by mes_referencia
            order by receita_total desc
        ) as ranking_receita_mes
    from monthly

)

select *
from final
