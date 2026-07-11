-- 4. Cross-sell: pares de categorias que aparecem no mesmo pedido
with categorias_pedido as (
    select distinct
        f.id_pedido,
        c.nome_categoria
    from public.fct_order_items as f
    inner join public.dim_categories as c
        on f.id_categoria = c.id_categoria
),

pares as (
    select
        a.nome_categoria as categoria_a,
        b.nome_categoria as categoria_b,
        a.id_pedido
    from categorias_pedido as a
    inner join categorias_pedido as b
        on a.id_pedido = b.id_pedido
        and a.nome_categoria < b.nome_categoria
),

ticket_pedido as (
    select
        id_pedido,
        sum(receita_liquida) as receita_pedido
    from public.fct_order_items
    group by id_pedido
)

select
    p.categoria_a,
    p.categoria_b,
    count(distinct p.id_pedido) as qtd_pedidos_juntos,
    round(avg(t.receita_pedido), 2) as ticket_medio_pedidos_com_par
from pares as p
inner join ticket_pedido as t
    on p.id_pedido = t.id_pedido
group by p.categoria_a, p.categoria_b
order by qtd_pedidos_juntos desc, ticket_medio_pedidos_com_par desc
limit 15;
