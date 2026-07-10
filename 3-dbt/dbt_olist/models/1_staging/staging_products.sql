with source as (
    select * from {{ source('northwind', 'raw_products') }}
),

renamed as (
    select
        product_id::integer as id_produto,
        trim(product_name) as nome_produto,
        supplier_id::integer as id_fornecedor,
        category_id::integer as id_categoria,
        trim(quantity_per_unit) as quantidade_por_unidade,
        unit_price::numeric(12, 2) as preco_unitario,
        units_in_stock::integer as unidades_estoque,
        units_on_order::integer as unidades_pedido,
        reorder_level::integer as nivel_reposicao,
        case
            when discontinued::text in ('1', 'true', 't', 'yes') then true
            else false
        end as descontinuado
    from source
)

select * from renamed
