SELECT DATE.LABEL_YYYY_MM_DD AS Date,
		DATE.LABEL_HH24 AS Hour,
		CDI.CUSTOMERLANG AS Language,
		R.RESOURCE_NAME,
		(R.AGENT_FIRST_NAME + ' ' + R.AGENT_LAST_NAME) AS 'Agent Name',
		COUNT (DISTINCT CASE WHEN IRF.TALK_COUNT>0 AND IT.INTERACTION_TYPE='Inbound' THEN IRF.INTERACTION_ID END) AS 'Inbound',
		COUNT (DISTINCT CASE WHEN IRF.TALK_COUNT>0 AND IT.INTERACTION_TYPE='Outbound' THEN IRF.INTERACTION_ID END) AS 'Outbound',
		COUNT (DISTINCT CASE WHEN IRF.TALK_COUNT>0 THEN IRF.INTERACTION_ID END) AS 'Total Calls',
		SUM(  IRF.RING_DURATION ) AS [RINGING DURATION],
		SUM(IRF.TALK_DURATION ) AS [TALK DURATION],
		SUM( IRF.HOLD_DURATION ) AS [HOLD DURATION],
		SUM( IRF.AFTER_CALL_WORK_DURATION ) AS [ACW DURATION]
		
			
FROM INTERACTION_RESOURCE_FACT AS IRF
		INNER JOIN INTERACTION_TYPE AS IT ON IRF.INTERACTION_TYPE_KEY=IT.INTERACTION_TYPE_KEY
		INNER JOIN TECHNICAL_DESCRIPTOR AS TD ON IRF.TECHNICAL_DESCRIPTOR_KEY=TD.TECHNICAL_DESCRIPTOR_KEY
		INNER JOIN DATE_TIME AS DATE ON IRF.START_DATE_TIME_KEY=DATE.DATE_TIME_KEY
		LEFT JOIN MEDIA_TYPE AS MT ON IRF.MEDIA_TYPE_KEY=MT.MEDIA_TYPE_KEY
			--присоединение внешних таблиц для получения страны из CUST_DIM_Interaction
		LEFT JOIN IRF_USER_DATA_KEYS AS UDK ON IRF.INTERACTION_RESOURCE_ID=UDK.INTERACTION_RESOURCE_ID
		LEFT JOIN CUST_DIM_INTERACTION AS CDI ON UDK.CUST_DIM_INTERACTION=CDI.ID
			--присоединяем таблицы для получения имя агента
		INNER JOIN RESOURCE_ AS R ON IRF.RESOURCE_KEY=R.RESOURCE_KEY

			
WHERE DATE.LABEL_YYYY_MM_DD>='2019-10-01'
	AND MT.MEDIA_NAME='Voice'
	AND CDI.CUSTOMERLANG != 'none' 
	AND CDI.CUSTOMERLANG != 'Test' AND CDI.CUSTOMERLANG != 'ES123'
	AND R.AGENT_FIRST_NAME IS NOT NULL
	AND R.AGENT_FIRST_NAME!='%Тест%'
	AND R.RESOURCE_TYPE='Agent'
	AND NOT R.RESOURCE_NAME IN ('aionov','daniel', 'aamelin')
	AND R.RESOURCE_NAME NOT LIKE '%Test%' AND R.RESOURCE_NAME NOT LIKE '%romanyuta%'
	AND  R.RESOURCE_NAME NOT LIKE '%yazykbaevr%' AND  R.RESOURCE_NAME NOT LIKE '%1000%'

			
GROUP BY DATE.LABEL_YYYY_MM_DD, DATE.LABEL_HH24, CDI.CUSTOMERLANG, R.RESOURCE_NAME, R.AGENT_FIRST_NAME, R.AGENT_LAST_NAME

ORDER BY DATE.LABEL_YYYY_MM_DD, DATE.LABEL_HH24,  CDI.CUSTOMERLANG