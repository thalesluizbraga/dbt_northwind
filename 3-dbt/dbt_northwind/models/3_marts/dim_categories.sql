with categories as (

    select *
    from {{ ref('staging_categories') }}

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
