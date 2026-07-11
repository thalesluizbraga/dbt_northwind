-- 5. Produtos âncora (1º pedido) vs expansão (pedidos seguintes)
with primeira_compra as (
    select
        id_cliente,
        min(data_pedido)::date as data_primeiro_pedido
    from public.fct_order_items
    group by id_cliente
),

itens_classificados as (
    select
        f.id_pedido,
        f.id_cliente,
        f.id_produto,
        f.nome_produto,
        f.id_categoria,
        f.data_pedido::date as data_pedido,
        f.receita_liquida,
        case
            when f.data_pedido::date = p.data_primeiro_pedido then 'ancora'
            else 'expansao'
        end as tipo_produto
    from public.fct_order_items as f
    inner join primeira_compra as p
        on f.id_cliente = p.id_cliente
),

resumo as (
    select
        tipo_produto,
        id_produto,
        nome_produto,
        count(*) as qtd_linhas,
        count(distinct id_cliente) as qtd_clientes,
        count(distinct id_pedido) as qtd_pedidos,
        round(sum(receita_liquida), 2) as receita_total,
        round(avg(receita_liquida), 2) as receita_media_item
    from itens_classificados
    group by tipo_produto, id_produto, nome_produto
)

select
    tipo_produto,
    id_produto,
    nome_produto,
    qtd_linhas,
    qtd_clientes,
    qtd_pedidos,
    receita_total,
    receita_media_item
from resumo
order by tipo_produto, receita_total desc;
