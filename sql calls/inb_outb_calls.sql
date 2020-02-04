SELECT

T1.ID,
T1.Date,
T1.Hours,
T1.[Agent Name],
count( distinct T1.[Inbound calls]) AS [Inbound calls],
count(distinct T2.[Outbound calls]) AS [Outbound calls],
count(distinct T2.[Outbound calls not connected]) AS [Outbound calls not connected],
COUNT( distinct T1.[Transferred]) AS [Transferred],
SUM(T1.[AVG Talk Time] + T2.[AVG Talk Time]) AS [AVG Talk Time,sec],
SUM(T1.[AVG Ring Dutation] + T2.[AVG Ring Dutation]) AS [AVG Ring Dutation,sec],
SUM(T1.[AVG Hold Time] + T2.[AVG Hold Time]) AS [AVG Hold Time,sec],
SUM(T1.[AVG After Call Work Time] + T2.[AVG After Call Work Time]) AS [AVG After Call Work Time,sec],
SUM(T1.[AHT Inbound]) AS [AHT Inb,sec],
sum(T2.[AHT outbound]) AS [AHT Outb,sec]

FROM 
(
SELECT DATE.LABEL_YYYY_MM_DD AS Date,
			cast(DATEADD(hour,2,DATE .CAL_DATE) AS time(0)) AS Hours,
		R.RESOURCE_NAME AS ID,
		(R.AGENT_FIRST_NAME + ' ' + R.AGENT_LAST_NAME) AS [Agent Name],
		count(distinct case when IRF.TALK_COUNT>0 then IRF.INTERACTION_ID end) as [Inbound calls],
		COUNT (DISTINCT CASE WHEN TD.TECHNICAL_RESULT='Transferred' THEN IRF.INTERACTION_ID END) AS [Transferred], --кол-во переведенных звонков
		/* Mediation Duration (cчитаем как ASA)- Истекшее время в секундах, в течение которого взаимодействие с клиентом проводилось в посредничестве 
		(в очередях, точках маршрутизации или IVR, не связанных с самообслуживанием) до достижения ресурса, представленного строкой IRF. 
		Это время измеряется от времени начала передачи IRF до момента, когда взаимодействие достигает ресурса, представленного строкой IRF*/
		ROUND(SUM(IRF.TALK_DURATION)/SUM(IRF.TALK_COUNT),2) AS [AVG Talk Time],--количество секунд, которое IVR самообслуживания или ресурс агента потратил на разговор по этому голосовому взаимодействию.
		ROUND(SUM(IRF.RING_DURATION)/SUM(IRF.TALK_COUNT),2) AS [AVG Ring Dutation],--количество секунд, в течение которых голосовое взаимодействие звонило на IVR самообслуживания или ресурсе агента
		ROUND(SUM(IRF.HOLD_DURATION)/SUM(IRF.TALK_COUNT),2) AS [AVG Hold Time],--количество секунд, в течение которых ресурс, связанный с этим голосовым взаимодействием, переводил взаимодействие в режим удержания
		CASE WHEN SUM(IRF.AFTER_CALL_WORK_COUNT)>0 THEN ROUND(SUM(IRF.AFTER_CALL_WORK_DURATION)/SUM(IRF.TALK_COUNT),2) ELSE '' END AS [AVG After Call Work Time],--Количество секунд, в течение которых ресурс IRF, связанный с этим голосовым взаимодействием, находился в состоянии ACW
		case when sum(IRF.TALK_COUNT)>0 then round(sum(IRF.TALK_DURATION)+sum(IRF.HOLD_DURATION)+sum(IRF.AFTER_CALL_WORK_DURATION)/sum(IRF.TALK_COUNT),2) else 0 end as [AHT Inbound]

				
FROM INTERACTION_RESOURCE_FACT AS IRF
		INNER JOIN INTERACTION_TYPE AS IT ON IRF.INTERACTION_TYPE_KEY=IT.INTERACTION_TYPE_KEY
		INNER JOIN TECHNICAL_DESCRIPTOR AS TD ON IRF.TECHNICAL_DESCRIPTOR_KEY=TD.TECHNICAL_DESCRIPTOR_KEY
		INNER JOIN DATE_TIME AS DATE ON IRF.START_DATE_TIME_KEY=DATE.DATE_TIME_KEY
		LEFT JOIN MEDIA_TYPE AS MT ON IRF.MEDIA_TYPE_KEY=MT.MEDIA_TYPE_KEY
					--присоединяем таблицы для получения страны (очереди ресурса)
		INNER JOIN RESOURCE_ AS R ON IRF.RESOURCE_KEY=R.RESOURCE_KEY
		INNER JOIN RESOURCE_ VQ ON IRF.LAST_VQUEUE_RESOURCE_KEY=VQ.RESOURCE_KEY
		

			
WHERE IRF.TALK_COUNT>0 
 	AND ( IT.INTERACTION_TYPE='Inbound')
	AND MT.MEDIA_NAME='Voice'
	AND VQ.RESOURCE_NAME<>'NONE'
	AND VQ.RESOURCE_NAME<>'VQ_Test_Phone_Inbound'
	AND VQ.RESOURCE_NAME<>'VQ_RU_Phone_Inbound'
	AND R.AGENT_FIRST_NAME IS NOT NULL
	AND R.AGENT_FIRST_NAME!='%Тест%'
	
	AND NOT R.RESOURCE_NAME IN ('aionov','daniel', 'aamelin')
	AND R.RESOURCE_NAME NOT LIKE '%Test%' AND R.RESOURCE_NAME NOT LIKE '%romanyuta%'
	AND  R.RESOURCE_NAME NOT LIKE '%yazykbaevr%' AND  R.RESOURCE_NAME NOT LIKE '%1000%'
		
GROUP BY DATE.LABEL_YYYY_MM_DD ,R.RESOURCE_NAME, R.AGENT_FIRST_NAME, R.AGENT_LAST_NAME, DATE.CAL_DATE

) AS T1

JOIN

(
SELECT DATE.LABEL_YYYY_MM_DD AS Date,
			cast(DATEADD(hour,2,DATE .CAL_DATE) AS time(0)) AS Hours,
			R.RESOURCE_NAME AS ID,
		count(distinct case when IRF.TALK_COUNT>0 then IRF.INTERACTION_ID end) as [Outbound calls] -- outbound calls
,count(distinct case when IRF.TALK_COUNT=0 then IRF.INTERACTION_ID end) as [Outbound calls not connected] -- outbound that didnt connect

		--COUNT (DISTINCT CASE WHEN TD.TECHNICAL_RESULT='Transferred' THEN IRF.INTERACTION_ID END) AS 'Transferred', --кол-во переведенных звонков
		/* Mediation Duration (cчитаем как ASA)- Истекшее время в секундах, в течение которого взаимодействие с клиентом проводилось в посредничестве 
		(в очередях, точках маршрутизации или IVR, не связанных с самообслуживанием) до достижения ресурса, представленного строкой IRF. 
		Это время измеряется от времени начала передачи IRF до момента, когда взаимодействие достигает ресурса, представленного строкой IRF*/
		,case when SUM(IRF.TALK_COUNT)>0 then ROUND(SUM(IRF.TALK_DURATION)/SUM(IRF.TALK_COUNT),2) end AS [AVG Talk Time],--количество секунд, которое IVR самообслуживания или ресурс агента потратил на разговор по этому голосовому взаимодействию.
		case when SUM(IRF.TALK_COUNT)>0 then ROUND(SUM(IRF.RING_DURATION)/SUM(IRF.TALK_COUNT),2) end AS [AVG Ring Dutation],--количество секунд, в течение которых голосовое взаимодействие звонило на IVR самообслуживания или ресурсе агента
		case when SUM(IRF.TALK_COUNT)>0 then ROUND(SUM(IRF.HOLD_DURATION)/SUM(IRF.TALK_COUNT),2) end AS [AVG Hold Time],--количество секунд, в течение которых ресурс, связанный с этим голосовым взаимодействием, переводил взаимодействие в режим удержания
		CASE WHEN SUM(IRF.AFTER_CALL_WORK_COUNT)>0 and SUM(IRF.TALK_COUNT)>0 then ROUND(SUM(IRF.AFTER_CALL_WORK_DURATION)/SUM(IRF.TALK_COUNT),2) ELSE '' END AS [AVG After Call Work Time]--Количество секунд, в течение которых ресурс IRF, связанный с этим голосовым взаимодействием, находился в состоянии ACW
		,case when SUM(IRF.TALK_COUNT)>0 then ROUND(SUM(IRF.TALK_DURATION+IRF.HOLD_DURATION+IRF.AFTER_CALL_WORK_DURATION )/SUM(IRF.TALK_COUNT),2) end AS [AHT Outbound]
				
FROM INTERACTION_RESOURCE_FACT AS IRF
		INNER JOIN INTERACTION_TYPE AS IT ON IRF.INTERACTION_TYPE_KEY=IT.INTERACTION_TYPE_KEY
		INNER JOIN TECHNICAL_DESCRIPTOR AS TD ON IRF.TECHNICAL_DESCRIPTOR_KEY=TD.TECHNICAL_DESCRIPTOR_KEY
		INNER JOIN DATE_TIME AS DATE ON IRF.START_DATE_TIME_KEY=DATE.DATE_TIME_KEY
		LEFT JOIN MEDIA_TYPE AS MT ON IRF.MEDIA_TYPE_KEY=MT.MEDIA_TYPE_KEY
					--присоединяем таблицы для получения страны (очереди ресурса)
		INNER JOIN RESOURCE_ AS R ON IRF.RESOURCE_KEY=R.RESOURCE_KEY
		INNER JOIN RESOURCE_ VQ ON IRF.LAST_VQUEUE_RESOURCE_KEY=VQ.RESOURCE_KEY
					--для получения страны
	--присоединение внешних таблиц для получения страны из CUST_DIM_Interaction
		LEFT JOIN IRF_USER_DATA_KEYS AS UDK ON IRF.INTERACTION_RESOURCE_ID=UDK.INTERACTION_RESOURCE_ID
		LEFT JOIN CUST_DIM_INTERACTION AS CDI ON UDK.CUST_DIM_INTERACTION=CDI.ID

			
WHERE IRF.TALK_COUNT>0
 	AND IT.INTERACTION_TYPE='Outbound'
	AND MT.MEDIA_NAME='Voice'
	AND VQ.RESOURCE_NAME<>'VQ_Test_Phone_Inbound'
	AND VQ.RESOURCE_NAME<>'VQ_RU_Phone_Inbound'
	AND R.AGENT_FIRST_NAME IS NOT NULL
	AND R.AGENT_FIRST_NAME!='%Тест%'
	
	AND NOT R.RESOURCE_NAME IN ('aionov','daniel', 'aamelin')
	AND R.RESOURCE_NAME NOT LIKE '%Test%' AND R.RESOURCE_NAME NOT LIKE '%romanyuta%'
	AND  R.RESOURCE_NAME NOT LIKE '%yazykbaevr%' AND  R.RESOURCE_NAME NOT LIKE '%1000%'
	
		
GROUP BY DATE.LABEL_YYYY_MM_DD, DATE.CAL_DATE, R.RESOURCE_NAME, R.AGENT_FIRST_NAME, R.AGENT_LAST_NAME

) AS T2

ON T1.ID = T2.ID
-- 
GROUP BY
T1.Date,
T1.Hours,
T1.[Agent Name],
T1.ID
