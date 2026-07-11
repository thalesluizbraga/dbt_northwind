with source as (
    select * from {{ source('northwind', 'raw_suppliers') }}
),

renamed as (
    select
        supplier_id::integer as id_fornecedor,
        trim(company_name) as nome_empresa,
        trim(contact_name) as nome_contato,
        trim(contact_title) as cargo_contato,
        trim(address) as endereco,
        trim(city) as cidade,
        trim(region) as regiao,
        trim(postal_code) as codigo_postal,
        trim(country) as pais,
        trim(phone) as telefone,
        trim(fax) as fax,
        trim(homepage) as website
    from source
)

select * from renamed
