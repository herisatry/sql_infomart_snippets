SELECT DATE.LABEL_YYYY_MM_DD AS Date,
		DATE.LABEL_HH24 AS Hour,
		CDI.CUSTOMERLANG AS Language,
		R.RESOURCE_NAME,
		(R.AGENT_FIRST_NAME + ' ' + R.AGENT_LAST_NAME) AS 'Agent Name',
		count(distinct case when CSF.AGENTS_COUNT>0 then CSF.MEDIA_SERVER_IXN_GUID end) as "Total # of chats",
		COUNT(DISTINCT CASE WHEN CSD.ENDED_BY='AGENT' THEN IRF.INTERACTION_ID END) AS 'Ended by Agent', -- количество чатов закрытых агентом
		COUNT(distinct case when TD2.RESULT_REASON in ('AbandonedWhileRinging','AbandonedFromHold') then CSF.MEDIA_SERVER_IXN_GUID end) as "# of unanswered/timed out chats",
		count(distinct case when TD2.TECHNICAL_RESULT in ('Transferred') then CSF.MEDIA_SERVER_IXN_GUID end) as "# of Transferred chats",
		SUM(CSF.HANDLE_DURATION) AS [Handle Time],
		CASE WHEN COUNT(case when CSF.AGENTS_COUNT>0 then CSF.MEDIA_SERVER_IXN_GUID end)>0 then sum(case when CSF.UNTIL_FIRST_REPLY_DURATION>0 then CSF.UNTIL_FIRST_REPLY_DURATION-CSF.UNTIL_FIRST_AGENT_DURATION else '' end)/count(case when CSF.AGENTS_COUNT>0 then CSF.MEDIA_SERVER_IXN_GUID end) else '' end as "Avg First Response Time", --агентом после присоединения к сессии
		case WHEN SUM(IRF.HANDLE_COUNT) >0 THEN ROUND(SUM(CSF.SESSION_DURATION)/SUM(IRF.HANDLE_COUNT),2) ELSE '' END AS 'AVG Session Time, sec',-- Ср. Продолжительность сеанса сервера чата в секундах. Обратите внимание, что сеансы асинхронного чата могут длиться несколько дней
		case WHEN SUM(IRF.HANDLE_COUNT) >0 THEN ROUND(SUM(CSF.AGENT_REPLY_DURATION)/SUM(IRF.HANDLE_COUNT),2) ELSE '' END AS 'AVG Reply Time, sec',--Cр. количество времени (в секундах), которое агент потратил на ответ клиенту
		case WHEN SUM(IRF.HANDLE_COUNT) >0 THEN ROUND(SUM(CSF.CUSTOMER_REPLY_DURATION)/SUM(IRF.HANDLE_COUNT),2) ELSE '' END AS 'AVG Customer Reply Time, sec',--Ср. количество времени (в секундах), которое клиент потратил на ответ агенту
		case WHEN SUM(IRF.HANDLE_COUNT) >0 THEN ROUND(SUM(CSF.AGENT_WAIT_DURATION)/SUM(IRF.HANDLE_COUNT),2) ELSE '' END AS 'AVG Wait Time for customer response, sec',--Ср. количество времени (в секундах), которое агент потратил на ожидание ответа от клиента
		case WHEN SUM(IRF.HANDLE_COUNT) >0 THEN ROUND(SUM(CSF.CUSTOMER_WAIT_DURATION)/SUM(IRF.HANDLE_COUNT),2) ELSE '' END AS 'AVG Wait Time for agent response, sec',--Cр. количество времени (в секундах), которое клиент потратил на ожидание ответа от агента
		case WHEN SUM(IRF.HANDLE_COUNT) >0 THEN ROUND(SUM(CSF.UNTIL_FIRST_AGENT_DURATION)/SUM(IRF.HANDLE_COUNT),2) ELSE '' END AS 'AVG Until First Agent Time , sec',--Cр. Время в секундах, в течение которого клиент ожидал, пока первый агент, видимый клиенту, не присоединится к сеансу. Агент не виден клиенту, пока взаимодействие не будет успешно перенаправлено и принято агентом.
		case WHEN SUM(IRF.HANDLE_COUNT) >0 THEN ROUND(SUM(CSF.UNTIL_FIRST_REPLY_DURATION)/SUM(IRF.HANDLE_COUNT),2) ELSE '' END AS 'AVG Greeting Time , sec'--Ср. Время, прошедшее с начала сеанса, в секундах, пока первый агент не отправит в сеанс чата первое приветствие / сообщение, видимое клиенту
		
		FROM INTERACTION_RESOURCE_FACT AS IRF
		INNER JOIN INTERACTION_TYPE AS IT ON IRF.INTERACTION_TYPE_KEY=IT.INTERACTION_TYPE_KEY
		INNER JOIN TECHNICAL_DESCRIPTOR AS TD ON IRF.TECHNICAL_DESCRIPTOR_KEY=TD.TECHNICAL_DESCRIPTOR_KEY
		LEFT JOIN INFOMART.dbo.TECHNICAL_DESCRIPTOR TD2 on IRF.TECHNICAL_DESCRIPTOR_KEY=TD2.TECHNICAL_DESCRIPTOR_KEY
		INNER JOIN DATE_TIME AS DATE ON IRF.START_DATE_TIME_KEY=DATE.DATE_TIME_KEY
		LEFT JOIN MEDIA_TYPE AS MT ON IRF.MEDIA_TYPE_KEY=MT.MEDIA_TYPE_KEY
			--присоединение внешних таблиц для получения страны из CUST_DIM_Interaction
		LEFT JOIN IRF_USER_DATA_KEYS AS UDK ON IRF.INTERACTION_RESOURCE_ID=UDK.INTERACTION_RESOURCE_ID
		LEFT JOIN CUST_DIM_INTERACTION AS CDI ON UDK.CUST_DIM_INTERACTION=CDI.ID
			--присоединяем таблицы для получения имя агента
		INNER JOIN RESOURCE_ AS R ON IRF.RESOURCE_KEY=R.RESOURCE_KEY
		  -- присоединяем таблицы для получения CHAT_SESSION_FACT
		INNER JOIN INTERACTION_FACT AS InF ON IRF.INTERACTION_ID=InF.INTERACTION_ID
		INNER JOIN CHAT_SESSION_FACT AS CSF ON InF.MEDIA_SERVER_IXN_GUID=CSF.MEDIA_SERVER_IXN_GUID
		  -- присоединяем таблицы для получения CHAT_SESSION_DIM
		INNER JOIN CHAT_SESSION_DIM AS CSD ON CSF.CHAT_SESSION_DIM_KEY=CSD.ID
	
			
WHERE
	MT.MEDIA_NAME='Chat'
	AND CDI.CUSTOMERLANG NOT LIKE 'none'
	AND CDI.CUSTOMERLANG NOT LIKE 'Test'
	AND CDI.CUSTOMERLANG NOT LIKE 'ES123'
	AND CDI.CUSTOMERLANG NOT LIKE 'RU'
	AND R.AGENT_FIRST_NAME IS NOT NULL 
	AND R.AGENT_FIRST_NAME NOT LIKE '%Test%'
	AND NOT R.RESOURCE_NAME IN ('aionov','daniel', 'aamelin')
	AND R.RESOURCE_NAME NOT LIKE '%romanyuta%'
	AND R.RESOURCE_NAME NOT LIKE '%yazykbaevr%'
	AND R.RESOURCE_NAME NOT LIKE '%1000%'
			
GROUP BY DATE.LABEL_YYYY_MM_DD, DATE.LABEL_HH24, CDI.CUSTOMERLANG, R.AGENT_FIRST_NAME, R.AGENT_LAST_NAME, R.RESOURCE_NAME

ORDER BY DATE.LABEL_YYYY_MM_DD, DATE.LABEL_HH24,CDI.CUSTOMERLANG