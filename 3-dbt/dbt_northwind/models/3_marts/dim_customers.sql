with customers as (

    select *
    from {{ ref('staging_customers') }}

),

final as (

    select
        id_cliente,
        nome_empresa,
        nome_contato,
        cargo_contato,
        endereco,
        cidade,
        regiao,
        codigo_postal,
        pais,
        telefone,
        fax
    from customers

)

select *
from final
