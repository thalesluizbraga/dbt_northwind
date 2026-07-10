with source as (
    select * from {{ source('northwind', 'raw_customers') }}
),

renamed as (
    select
        trim(customer_id)::text as id_cliente,
        trim(company_name) as nome_empresa,
        trim(contact_name) as nome_contato,
        trim(contact_title) as cargo_contato,
        trim(address) as endereco,
        trim(city) as cidade,
        trim(region) as regiao,
        trim(postal_code) as codigo_postal,
        trim(country) as pais,
        trim(phone) as telefone,
        trim(fax) as fax
    from source
)

select * from renamed
