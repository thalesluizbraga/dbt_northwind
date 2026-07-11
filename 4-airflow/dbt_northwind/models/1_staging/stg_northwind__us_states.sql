with source as (
    select * from {{ source('northwind', 'raw_us_states') }}
),

renamed as (
    select
        state_id::integer as id_estado,
        trim(state_name) as nome_estado,
        upper(trim(state_abbr)) as sigla_estado,
        lower(trim(state_region)) as regiao_estado
    from source
)

select * from renamed
