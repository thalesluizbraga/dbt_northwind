with source as (
    select * from {{ source('northwind', 'raw_order_details') }}
),

renamed as (
    select
        order_id::integer as id_pedido,
        product_id::integer as id_produto,
        unit_price::numeric(12, 2) as preco_unitario,
        quantity::integer as quantidade,
        discount::numeric(5, 4) as desconto
    from source
)

select * from renamed
