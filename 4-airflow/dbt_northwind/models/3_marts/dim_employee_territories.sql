with employee_territories as (

    select *
    from {{ ref('stg_northwind__employee_territories') }}

),

final as (

    select
        id_funcionario,
        id_territorio
    from employee_territories

)

select *
from final
