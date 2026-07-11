with regions as (

    select *
    from {{ ref('staging_regions') }}

),

final as (

    select
        id_regiao,
        descricao_regiao
    from regions

)

select *
from final
