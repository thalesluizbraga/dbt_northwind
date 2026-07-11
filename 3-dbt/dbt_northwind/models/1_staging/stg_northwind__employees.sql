with source as (
    select * from {{ source('northwind', 'raw_employees') }}
),

renamed as (
    select
        employee_id::integer as id_funcionario,
        trim(last_name) as sobrenome,
        trim(first_name) as nome,
        trim(title) as cargo,
        trim(title_of_courtesy) as tratamento,
        birth_date::date as data_nascimento,
        hire_date::date as data_contratacao,
        trim(address) as endereco,
        trim(city) as cidade,
        trim(region) as regiao,
        trim(postal_code) as codigo_postal,
        trim(country) as pais,
        trim(home_phone) as telefone,
        trim(extension::text) as ramal,
        trim(notes) as observacoes,
        reports_to::integer as id_supervisor,
        trim(photo_path) as caminho_foto
    from source
)

select * from renamed
