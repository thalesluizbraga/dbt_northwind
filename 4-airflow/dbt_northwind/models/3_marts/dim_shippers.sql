with shippers as (

    select *
    from {{ ref('stg_northwind__shippers') }}

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
