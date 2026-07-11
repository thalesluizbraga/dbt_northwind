with categories as (

    select *
    from {{ ref('stg_northwind__categories') }}

),

final as (

    select
        id_categoria,
        nome_categoria,
        descricao
    from categories

)

select *
from final
