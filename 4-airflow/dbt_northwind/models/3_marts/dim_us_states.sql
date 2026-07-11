with us_states as (

    select *
    from {{ ref('stg_northwind__us_states') }}

),

final as (

    select
        id_estado,
        nome_estado,
        sigla_estado,
        regiao_estado
    from us_states

)

select *
from final
