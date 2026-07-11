with customer_demographics as (

    select *
    from {{ ref('staging_customer_demographics') }}

),

final as (

    select
        id_tipo_cliente,
        descricao_tipo_cliente
    from customer_demographics

)

select *
from final
