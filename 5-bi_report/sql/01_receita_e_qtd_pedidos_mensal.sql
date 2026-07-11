-- 1. Ticket médio por pedido (visão geral + evolução mensal)
with final as (
    select
        mes_referencia,
        receita_mes,
        qtd_pedidos_mes
    from public.agg_customer_metrics_monthly
    order by mes_referencia asc
)


select 
*
from 
final