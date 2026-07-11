-- 7. Top 10 combinações de categoria e região com maior ticket médio
with pedidos_categoria_regiao as (
    select
        f.id_pedido,
        coalesce(cat.nome_categoria, 'Categoria sem nome') as nome_categoria,
        coalesce(nullif(trim(f.regiao_entrega), ''), 'Região não informada') as regiao,
        sum(f.receita_liquida) as receita_pedido_categoria_regiao
    from public.fct_order_items as f
    left join public.dim_categories as cat
        on f.id_categoria = cat.id_categoria
    group by
        f.id_pedido,
        coalesce(cat.nome_categoria, 'Categoria sem nome'),
        coalesce(nullif(trim(f.regiao_entrega), ''), 'Região não informada')
),

resumo as (
    select
        nome_categoria,
        regiao,
        count(distinct id_pedido) as qtd_pedidos,
        round(sum(receita_pedido_categoria_regiao), 2) as receita_total,
        round(avg(receita_pedido_categoria_regiao), 2) as ticket_medio
    from pedidos_categoria_regiao
    group by nome_categoria, regiao
)

select
    row_number() over (order by ticket_medio desc, receita_total desc) as ranking_ticket_medio,
    nome_categoria,
    regiao,
    qtd_pedidos,
    receita_total,
    ticket_medio
from resumo
order by ticket_medio desc, receita_total desc
limit 10;
