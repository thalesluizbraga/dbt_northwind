with products as (

    select *
    from {{ ref('staging_products') }}

),

final as (

    select
        id_produto,
        nome_produto,
        id_fornecedor,
        id_categoria,
        quantidade_por_unidade,
        preco_unitario,
        unidades_estoque,
        unidades_pedido,
        nivel_reposicao,
        descontinuado
    from products

)

select *
from final
