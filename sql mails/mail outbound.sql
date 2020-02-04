SELECT
R.RESOURCE_NAME, DT.LABEL_YYYY_MM_DD_HH24, MT.MEDIA_NAME,
COUNT(IRF.INTERACTION_ID) AS [TOTAL OUTBOUND ]


FROM INTERACTION_RESOURCE_FACT IRF

INNER JOIN MEDIA_TYPE MT ON IRF.MEDIA_TYPE_KEY = MT.MEDIA_TYPE_KEY
INNER JOIN DATE_TIME DT ON IRF.START_DATE_TIME_KEY = DT.DATE_TIME_KEY
INNER JOIN RESOURCE_ R ON IRF.RESOURCE_KEY = R.RESOURCE_KEY
INNER JOIN INTERACTION_TYPE IT ON IRF.INTERACTION_TYPE_KEY = IT.INTERACTION_TYPE_KEY

WHERE (IRF.HANDLE_COUNT <> 0 AND IT.INTERACTION_TYPE_CODE = 'OUTBOUND')

AND NOT R.RESOURCE_NAME IN ('aionov','daniel', 'aamelin')
AND R.RESOURCE_NAME NOT LIKE '%Test%' AND R.RESOURCE_NAME NOT LIKE '%romanyuta%'
AND  R.RESOURCE_NAME NOT LIKE '%yazykbaevr%' AND  R.RESOURCE_NAME NOT LIKE '%1000%'

GROUP BY R.RESOURCE_NAME, DT.LABEL_YYYY_MM_DD_HH24, MT.MEDIA_NAME
HAVING MT.MEDIA_NAME = 'Email' 
ORDER BY DT.LABEL_YYYY_MM_DD_HH24, MT.MEDIA_NAME
