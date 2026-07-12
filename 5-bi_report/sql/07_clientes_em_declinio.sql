-- 9. Clientes em declínio — periodicidade média entre compras
-- Potencial churn: dias desde o último pedido acima do intervalo médio histórico do cliente
with data_referencia as (
    select max(data_pedido)::date as data_referencia
    from public.fct_order_items
),

pedidos_distintos as (
    select distinct
        id_cliente,
        data_pedido::date as data_pedido
    from public.fct_order_items
),

pedidos_ordenados as (
    select
        id_cliente,
        data_pedido,
        lag(data_pedido) over (
            partition by id_cliente
            order by data_pedido
        ) as data_pedido_anterior
    from pedidos_distintos
),

intervalos as (
    select
        id_cliente,
        (data_pedido - data_pedido_anterior) as dias_entre_pedidos
    from pedidos_ordenados
    where data_pedido_anterior is not null
),

intervalo_medio_cliente as (
    select
        id_cliente,
        round(avg(dias_entre_pedidos), 2) as intervalo_medio_dias,
        count(*) + 1 as total_pedidos
    from intervalos
    group by id_cliente
),

ultimo_pedido as (
    select
        id_cliente,
        max(data_pedido) as data_ultimo_pedido,
        min(data_pedido) as data_primeiro_pedido
    from pedidos_distintos
    group by id_cliente
),

periodicidade_media_global as (
    select round(avg(intervalo_medio_dias), 2) as periodicidade_media_global
    from intervalo_medio_cliente
),

clientes_metricas as (
    select
        u.id_cliente,
        coalesce(c.nome_empresa, 'Cliente sem nome') as nome_empresa,
        u.data_primeiro_pedido,
        u.data_ultimo_pedido,
        d.data_referencia,
        coalesce(im.total_pedidos, 1) as total_pedidos,
        coalesce(im.intervalo_medio_dias, pg.periodicidade_media_global) as intervalo_medio_dias,
        pg.periodicidade_media_global,
        (d.data_referencia - u.data_ultimo_pedido) as dias_desde_ultimo_pedido,
        round(
            (d.data_referencia - u.data_ultimo_pedido)::numeric
            / nullif(coalesce(im.intervalo_medio_dias, pg.periodicidade_media_global), 0),
            2
        ) as razao_atraso_vs_media,
        case
            when (d.data_referencia - u.data_ultimo_pedido)
                > coalesce(im.intervalo_medio_dias, pg.periodicidade_media_global)
            then true
            else false
        end as potencial_churn
    from ultimo_pedido as u
    cross join data_referencia as d
    cross join periodicidade_media_global as pg
    left join intervalo_medio_cliente as im
        on u.id_cliente = im.id_cliente
    left join public.dim_customers as c
        on u.id_cliente = c.id_cliente
)

select
    id_cliente,
    nome_empresa,
    data_primeiro_pedido,
    data_ultimo_pedido,
    data_referencia,
    total_pedidos,
    intervalo_medio_dias,
    periodicidade_media_global,
    dias_desde_ultimo_pedido,
    razao_atraso_vs_media,
    potencial_churn
from clientes_metricas
order by potencial_churn desc, dias_desde_ultimo_pedido desc, razao_atraso_vs_media desc;
