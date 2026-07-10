with source as (
    select * from {{ source('northwind', 'raw_employee_territories') }}
),

renamed as (
    select
        employee_id::integer as id_funcionario,
        trim(territory_id::text) as id_territorio
    from source
)

select * from renamed
