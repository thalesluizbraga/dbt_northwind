with shippers as (

    select *
    from {{ ref('staging_shippers') }}

),

final as (

    select
        id_transportadora,
        nome_empresa,
        telefone
    from shippers

)

select *
from final
