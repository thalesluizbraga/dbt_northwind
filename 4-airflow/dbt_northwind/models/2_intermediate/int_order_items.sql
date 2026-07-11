with orders as (
    select
        id_pedido,
        id_cliente,
        id_funcionario,
        data_pedido,
        data_requerida,
        data_envio,
        id_transportadora,
        frete,
        nome_destinatario,
        endereco_entrega,
        cidade_entrega,
        regiao_entrega,
        cep_entrega,
        pais_entrega
    from {{ ref('stg_northwind__orders') }}
), 

order_details as (

    select
        id_pedido,
        id_produto,
        preco_unitario,
        quantidade,
        desconto
    from {{ ref('stg_northwind__order_details') }}

), 

final as (

select 
        a.id_pedido,
        a.id_produto,
        a.preco_unitario,
        a.quantidade,
        a.desconto, 
         b.id_cliente,
        b.id_funcionario,
        b.data_pedido,
        b.data_requerida,
        b.data_envio,
        b.id_transportadora,
        b.frete,
        b.nome_destinatario,
        b.endereco_entrega,
        b.cidade_entrega,
        b.regiao_entrega,
        b.cep_entrega,
        b.pais_entrega
from order_details as a 
left join orders as b on a.id_pedido = b.id_pedido


)

select * from final