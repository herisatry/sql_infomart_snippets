SELECT lang,customer_info, COUNT(*) AS 'Nr interactions'
FROM [INTERACTIONS].[dbo].[interactions]
WHERE customer_info IS NOT NULL AND media_type ='email' AND queue = 'BasicEmailInbound.default.EmailInboundContactProcessed' 
AND destinations is NULL AND lang IN ('ES','FR','IT','DE','EN')
GROUP BY customer_info , lang
ORDER BY 'Nr interactions' DESC