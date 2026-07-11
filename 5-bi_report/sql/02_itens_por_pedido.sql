-- 2. Itens por pedido e quantidade média
with pedidos as (
    select
        id_pedido,
        mes_pedido,
        count(*) as qtd_itens,
        sum(quantidade) as qtd_unidades,
        sum(receita_liquida) as receita_pedido
    from public.fct_order_items
    group by id_pedido, mes_pedido
)

select
    'geral' as nivel,
    null::date as mes_pedido,
    round(avg(qtd_itens), 2) as media_itens_por_pedido,
    round(avg(qtd_unidades), 2) as media_unidades_por_pedido,
    round(avg(receita_pedido / nullif(qtd_itens, 0)), 2) as receita_media_por_item,
    round(avg(receita_pedido / nullif(qtd_unidades, 0)), 2) as receita_media_por_unidade
from pedidos

union all

select
    'mensal' as nivel,
    mes_pedido,
    round(avg(qtd_itens), 2) as media_itens_por_pedido,
    round(avg(qtd_unidades), 2) as media_unidades_por_pedido,
    round(avg(receita_pedido / nullif(qtd_itens, 0)), 2) as receita_media_por_item,
    round(avg(receita_pedido / nullif(qtd_unidades, 0)), 2) as receita_media_por_unidade
from pedidos
group by mes_pedido
order by nivel, mes_pedido;
