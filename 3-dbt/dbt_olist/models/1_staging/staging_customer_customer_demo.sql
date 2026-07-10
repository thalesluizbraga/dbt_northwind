with source as (
    select * from {{ source('northwind', 'raw_customer_customer_demo') }}
),

renamed as (
    select
        trim(customer_id)::text as id_cliente,
        trim(customer_type_id)::text as id_tipo_cliente
    from source
)

select * from renamed
