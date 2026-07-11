with employee_territories as (

    select *
    from {{ ref('staging_employee_territories') }}

),

final as (

    select
        id_funcionario,
        id_territorio
    from employee_territories

)

select *
from final
