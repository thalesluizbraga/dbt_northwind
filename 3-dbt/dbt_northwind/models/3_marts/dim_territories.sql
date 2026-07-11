with territories as (

    select *
    from {{ ref('staging_territories') }}

),

final as (

    select
        id_territorio,
        descricao_territorio,
        id_regiao
    from territories

)

select *
from final
