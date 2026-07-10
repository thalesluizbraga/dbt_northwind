with source as (
    select * from {{ source('northwind', 'raw_territories') }}
),

renamed as (
    select
        trim(territory_id::text) as id_territorio,
        trim(territory_description) as descricao_territorio,
        region_id::integer as id_regiao
    from source
)

select * from renamed
