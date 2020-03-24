USE INTERACTIONS

SELECT i0.lang as [lang], count(*) as [Qty] , MIN(i0.moved_to_queue_at) AS [oldest email]

FROM interactions i0

where i0.queue = 'BasicEmailInbound.default.EmailInboundContactProcessed'  AND i0.destinations is NULL AND ( i0.customer_info  NOT LIKE '%trust%' OR i0.ext_type NOT LIKE '%trust%' ) group by i0.lang