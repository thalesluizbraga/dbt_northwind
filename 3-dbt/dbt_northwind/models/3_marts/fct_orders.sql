with final as (

select 
        id_pedido,
        id_produto,
        preco_unitario,
        quantidade,
        desconto, 
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
from {{ ref('int_order_items') }}

)

select * from final