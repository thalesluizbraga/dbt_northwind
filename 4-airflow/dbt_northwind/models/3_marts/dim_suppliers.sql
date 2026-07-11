with suppliers as (

    select *
    from {{ ref('stg_northwind__suppliers') }}

),

final as (

    select
        id_fornecedor,
        nome_empresa,
        nome_contato,
        cargo_contato,
        endereco,
        cidade,
        regiao,
        codigo_postal,
        pais,
        telefone,
        fax,
        website
    from suppliers

)

select *
from final
