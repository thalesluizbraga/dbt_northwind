with source as (
    select * from {{ source('northwind', 'raw_region') }}
),

renamed as (
    select
        region_id::integer as id_regiao,
        trim(region_description) as descricao_regiao
    from source
)

select * from renamed
