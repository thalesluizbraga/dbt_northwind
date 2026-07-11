with customer_customer_demo as (

    select *
    from {{ ref('staging_customer_customer_demo') }}

),

final as (

    select
        id_cliente,
        id_tipo_cliente
    from customer_customer_demo

)

select *
from final
