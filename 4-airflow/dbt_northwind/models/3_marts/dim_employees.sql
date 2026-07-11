with employees as (

    select *
    from {{ ref('stg_northwind__employees') }}

),

final as (

    select
        id_funcionario,
        sobrenome,
        nome,
        cargo,
        tratamento,
        data_nascimento,
        data_contratacao,
        endereco,
        cidade,
        regiao,
        codigo_postal,
        pais,
        telefone,
        ramal,
        observacoes,
        id_supervisor,
        caminho_foto
    from employees

)

select *
from final
