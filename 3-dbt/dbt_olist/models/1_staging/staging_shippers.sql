with source as (
    select * from {{ source('northwind', 'raw_shippers') }}
),

renamed as (
    select
        shipper_id::integer as id_transportadora,
        trim(company_name) as nome_empresa,
        trim(phone) as telefone
    from source
)

select * from renamed
