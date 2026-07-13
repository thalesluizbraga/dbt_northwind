-- 1. Ticket médio por pedido (visão geral + evolução mensal)
with final as (
    select
        mes_referencia,
        sum(receita_mes) as receita_mes,
        count(qtd_pedidos_mes) as qtd_pedidos_mes
    from public.agg_customer_metrics_monthly
    group by mes_referencia
    order by mes_referencia asc

)


select 
*
from 
final