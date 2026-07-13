-- 9. Impacto do desconto no ticket
-- Pedido com desconto: pelo menos um item com desconto > 0
with pedidos as (
    select
        f.id_pedido,
        sum(f.receita_liquida) as ticket,
        sum(f.valor_desconto) as valor_desconto_pedido,
        max(case when f.desconto > 0 then 1 else 0 end) as pedido_com_desconto
    from public.fct_order_items as f
    group by f.id_pedido
),

resumo_pedido as (
    select
        case
            when pedido_com_desconto = 1 then 'com_desconto'
            else 'sem_desconto'
        end as tipo_pedido,
        count(*) as qtd_pedidos,
        round(100.0 * count(*) / sum(count(*)) over (), 2) as pct_pedidos,
        round(avg(ticket), 2) as ticket_medio,
        round(
            avg(case when valor_desconto_pedido > 0 then valor_desconto_pedido end),
            2
        ) as desconto_medio,
        round(sum(ticket), 2) as receita_total
    from pedidos
    group by 1
),

itens_enriquecidos as (
    select
        f.id_pedido,
        f.id_categoria,
        f.id_funcionario,
        coalesce(nullif(trim(f.regiao_entrega), ''), 'Região não informada') as regiao,
        coalesce(cat.nome_categoria, 'Categoria sem nome') as nome_categoria,
        coalesce(e.nome || ' ' || e.sobrenome, 'Funcionário não informado') as nome_funcionario,
        f.desconto,
        f.valor_desconto,
        f.receita_liquida,
        f.tem_desconto
    from public.fct_order_items as f
    left join public.dim_categories as cat
        on f.id_categoria = cat.id_categoria
    left join public.dim_employees as e
        on f.id_funcionario = e.id_funcionario
),

por_categoria as (
    select
        'categoria' as dimensao,
        nome_categoria as rotulo,
        count(distinct id_pedido) as qtd_pedidos,
        round(avg(case when desconto > 0 then valor_desconto end), 2) as desconto_medio,
        round(avg(case when desconto > 0 then desconto end), 4) as desconto_medio_pct,
        round(100.0 * sum(case when tem_desconto then 1 else 0 end) / count(*), 2) as pct_itens_com_desconto,
        round(avg(receita_liquida), 2) as ticket_medio_item
    from itens_enriquecidos
    group by nome_categoria
),

por_funcionario as (
    select
        'funcionario' as dimensao,
        nome_funcionario as rotulo,
        count(distinct id_pedido) as qtd_pedidos,
        round(avg(case when desconto > 0 then valor_desconto end), 2) as desconto_medio,
        round(avg(case when desconto > 0 then desconto end), 4) as desconto_medio_pct,
        round(100.0 * sum(case when tem_desconto then 1 else 0 end) / count(*), 2) as pct_itens_com_desconto,
        round(avg(receita_liquida), 2) as ticket_medio_item
    from itens_enriquecidos
    group by nome_funcionario
),

por_regiao as (
    select
        'regiao' as dimensao,
        regiao as rotulo,
        count(distinct id_pedido) as qtd_pedidos,
        round(avg(case when desconto > 0 then valor_desconto end), 2) as desconto_medio,
        round(avg(case when desconto > 0 then desconto end), 4) as desconto_medio_pct,
        round(100.0 * sum(case when tem_desconto then 1 else 0 end) / count(*), 2) as pct_itens_com_desconto,
        round(avg(receita_liquida), 2) as ticket_medio_item
    from itens_enriquecidos
    group by regiao
),

resultado as (
    select
        'resumo' as secao,
        tipo_pedido as rotulo,
        qtd_pedidos,
        pct_pedidos,
        ticket_medio,
        desconto_medio,
        receita_total,
        null::numeric as desconto_medio_pct,
        null::numeric as pct_itens_com_desconto,
        null::numeric as ticket_medio_item
    from resumo_pedido

    union all

    select
        dimensao as secao,
        rotulo,
        qtd_pedidos,
        null::numeric as pct_pedidos,
        null::numeric as ticket_medio,
        desconto_medio,
        null::numeric as receita_total,
        desconto_medio_pct,
        pct_itens_com_desconto,
        ticket_medio_item
    from por_categoria

    union all

    select
        dimensao as secao,
        rotulo,
        qtd_pedidos,
        null::numeric as pct_pedidos,
        null::numeric as ticket_medio,
        desconto_medio,
        null::numeric as receita_total,
        desconto_medio_pct,
        pct_itens_com_desconto,
        ticket_medio_item
    from por_funcionario

    union all

    select
        dimensao as secao,
        rotulo,
        qtd_pedidos,
        null::numeric as pct_pedidos,
        null::numeric as ticket_medio,
        desconto_medio,
        null::numeric as receita_total,
        desconto_medio_pct,
        pct_itens_com_desconto,
        ticket_medio_item
    from por_regiao
)

select
    secao,
    rotulo,
    qtd_pedidos,
    pct_pedidos,
    ticket_medio,
    desconto_medio,
    receita_total,
    desconto_medio_pct,
    pct_itens_com_desconto,
    ticket_medio_item
from resultado
order by
    case secao
        when 'resumo' then 1
        when 'categoria' then 2
        when 'funcionario' then 3
        when 'regiao' then 4
    end,
    case when secao = 'resumo' and rotulo = 'com_desconto' then 1 else 2 end,
    desconto_medio desc nulls last;
