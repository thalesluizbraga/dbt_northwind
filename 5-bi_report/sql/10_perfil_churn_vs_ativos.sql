-- 10. Perfil potencial churn vs ativos (país, região, cidade)
-- Usa a mesma regra da análise 09 para classificar os clientes
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
        round(avg(dias_entre_pedidos), 2) as intervalo_medio_dias
    from intervalos
    group by id_cliente
),

ultimo_pedido as (
    select
        id_cliente,
        max(data_pedido) as data_ultimo_pedido
    from pedidos_distintos
    group by id_cliente
),

periodicidade_media_global as (
    select round(avg(intervalo_medio_dias), 2) as periodicidade_media_global
    from intervalo_medio_cliente
),

clientes_grupo as (
    select
        u.id_cliente,
        case
            when (d.data_referencia - u.data_ultimo_pedido)
                > coalesce(im.intervalo_medio_dias, pg.periodicidade_media_global)
            then 'potencial_churn'
            else 'ativo'
        end as grupo
    from ultimo_pedido as u
    cross join data_referencia as d
    cross join periodicidade_media_global as pg
    left join intervalo_medio_cliente as im
        on u.id_cliente = im.id_cliente
),

clientes_dim as (
    select
        cg.id_cliente,
        cg.grupo,
        coalesce(nullif(trim(c.pais), ''), 'País não informado') as pais,
        coalesce(nullif(trim(c.regiao), ''), 'Região não informada') as regiao,
        coalesce(nullif(trim(c.cidade), ''), 'Cidade não informada') as cidade
    from clientes_grupo as cg
    left join public.dim_customers as c
        on cg.id_cliente = c.id_cliente
),

por_pais as (
    select
        'pais' as dimensao,
        pais as valor,
        grupo,
        count(distinct id_cliente) as qtd_clientes
    from clientes_dim
    group by pais, grupo
),

por_regiao as (
    select
        'regiao' as dimensao,
        regiao as valor,
        grupo,
        count(distinct id_cliente) as qtd_clientes
    from clientes_dim
    group by regiao, grupo
),

por_cidade as (
    select
        'cidade' as dimensao,
        cidade as valor,
        grupo,
        count(distinct id_cliente) as qtd_clientes
    from clientes_dim
    group by cidade, grupo
),

unificado as (
    select * from por_pais
    union all
    select * from por_regiao
    union all
    select * from por_cidade
)

select
    dimensao,
    valor,
    grupo,
    qtd_clientes,
    round(
        100.0 * qtd_clientes / nullif(sum(qtd_clientes) over (partition by dimensao, grupo), 0),
        2
    ) as pct_no_grupo
from unificado
order by dimensao, grupo, qtd_clientes desc, valor;
