with order_items as (

    select *
    from {{ ref('int_order_items') }}

),

products as (

    select
        id_produto,
        id_categoria,
        nome_produto
    from {{ ref('stg_northwind__products') }}

),

enriched as (

    select
        o.id_pedido,
        o.id_produto,
        o.id_cliente,
        o.id_funcionario,
        o.id_transportadora,
        p.id_categoria,
        p.nome_produto,
        o.data_pedido,
        date_trunc('month', o.data_pedido)::date as mes_pedido,
        o.data_requerida,
        o.data_envio,
        o.preco_unitario,
        o.quantidade,
        o.desconto,
        round((o.preco_unitario * o.quantidade)::numeric, 2) as receita_bruta,
        round((o.preco_unitario * o.quantidade * o.desconto)::numeric, 2) as valor_desconto,
        round((o.preco_unitario * o.quantidade * (1 - o.desconto))::numeric, 2) as receita_liquida,
        (o.desconto > 0) as tem_desconto,
        o.frete,
        o.nome_destinatario,
        o.endereco_entrega,
        o.cidade_entrega,
        o.regiao_entrega,
        o.cep_entrega,
        o.pais_entrega,
        case
            when o.data_envio is not null
                and o.data_requerida is not null
                and o.data_envio::date > o.data_requerida::date
            then true
            else false
        end as entrega_atrasada,
        case
            when o.data_envio is not null and o.data_pedido is not null
            then (o.data_envio::date - o.data_pedido::date)
        end as dias_para_envio
    from order_items as o
    left join products as p
        on o.id_produto = p.id_produto

),

final as (

    select
        id_pedido,
        id_produto,
        id_cliente,
        id_funcionario,
        id_transportadora,
        id_categoria,
        nome_produto,
        data_pedido,
        mes_pedido,
        data_requerida,
        data_envio,
        preco_unitario,
        quantidade,
        desconto,
        receita_bruta,
        valor_desconto,
        receita_liquida,
        tem_desconto,
        frete,
        nome_destinatario,
        endereco_entrega,
        cidade_entrega,
        regiao_entrega,
        cep_entrega,
        pais_entrega,
        entrega_atrasada,
        dias_para_envio
    from enriched

)

select *
from final
