with source as (
    select * from {{ source('northwind', 'raw_categories') }}
),

renamed as (
    select
        category_id::integer as id_categoria,
        trim(category_name) as nome_categoria,
        trim(description) as descricao
    from source
)

select * from renamed
