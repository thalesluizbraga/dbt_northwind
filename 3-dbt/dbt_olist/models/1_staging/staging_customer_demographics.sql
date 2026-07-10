with source as (
    select * from {{ source('northwind', 'raw_customer_demographics') }}
),

renamed as (
    select
        trim(customer_type_id)::text as id_tipo_cliente,
        trim(customer_desc) as descricao_tipo_cliente
    from source
)

select * from renamed
