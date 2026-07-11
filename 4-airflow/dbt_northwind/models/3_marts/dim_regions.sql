with regions as (

    select *
    from {{ ref('stg_northwind__regions') }}

),

final as (

    select
        id_regiao,
        descricao_regiao
    from regions

)

select *
from final
