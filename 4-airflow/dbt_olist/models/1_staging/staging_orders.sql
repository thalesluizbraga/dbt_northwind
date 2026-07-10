with source as (
    select * from {{ source('northwind', 'raw_orders') }}
),

renamed as (
    select
        order_id::integer as id_pedido,
        trim(customer_id)::text as id_cliente,
        employee_id::integer as id_funcionario,
        order_date::timestamp as data_pedido,
        required_date::timestamp as data_requerida,
        shipped_date::timestamp as data_envio,
        ship_via::integer as id_transportadora,
        freight::numeric(12, 2) as frete,
        trim(ship_name) as nome_destinatario,
        trim(ship_address) as endereco_entrega,
        trim(ship_city) as cidade_entrega,
        trim(ship_region) as regiao_entrega,
        trim(ship_postal_code) as cep_entrega,
        trim(ship_country) as pais_entrega
    from source
)

select * from renamed
