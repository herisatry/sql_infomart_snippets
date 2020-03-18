USE INTERACTIONS

SELECT lang as [lang], count(*) as [Qty] , min(moved_to_queue_at) AS [oldest email date]

FROM interactions where queue = 'BasicEmailInbound.default.EmailInboundContactProcessed'  AND destinations is NULL AND ( customer_info  NOT LIKE '%trust%' OR ext_type NOT LIKE '%trust%') group by lang