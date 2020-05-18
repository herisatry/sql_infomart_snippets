USE INFOMART;

SELECT DATE.LABEL_YYYY_MM_DD AS Date,
		CDI.CUSTOMERLANG AS Language,
		CONCAT(R.AGENT_LAST_NAME, ' ', R.AGENT_FIRST_NAME) AS 'Agent Name',
		COUNT (DISTINCT IRF.INTERACTION_ID) AS 'Outbound calls',

		COUNT (DISTINCT CASE WHEN TD.TECHNICAL_RESULT='Transferred' THEN IRF.INTERACTION_ID END) AS 'Transferred', --кол-во переведенных звонков
		/* Mediation Duration (cчитаем как ASA)- Истекшее время в секундах, в течение которого взаимодействие с клиентом проводилось в посредничестве 
		(в очередях, точках маршрутизации или IVR, не связанных с самообслуживанием) до достижения ресурса, представленного строкой IRF. 
		Это время измеряется от времени начала передачи IRF до момента, когда взаимодействие достигает ресурса, представленного строкой IRF*/
		ROUND(SUM(IRF.TALK_DURATION)/SUM(IRF.TALK_COUNT),2) AS 'AVG Talk Time, sec',--количество секунд, которое IVR самообслуживания или ресурс агента потратил на разговор по этому голосовому взаимодействию.
		ROUND(SUM(IRF.RING_DURATION)/SUM(IRF.TALK_COUNT),2) AS 'AVG Ring Dutation, sec',--количество секунд, в течение которых голосовое взаимодействие звонило на IVR самообслуживания или ресурсе агента
		ROUND(SUM(IRF.HOLD_DURATION)/SUM(IRF.TALK_COUNT),2) AS 'AVG Hold Time, sec',--количество секунд, в течение которых ресурс, связанный с этим голосовым взаимодействием, переводил взаимодействие в режим удержания
		CASE WHEN SUM(IRF.AFTER_CALL_WORK_COUNT)>0 THEN ROUND(SUM(IRF.AFTER_CALL_WORK_DURATION)/SUM(IRF.TALK_COUNT),2) ELSE '' END AS 'AVG After Call Work Time, sec',--Количество секунд, в течение которых ресурс IRF, связанный с этим голосовым взаимодействием, находился в состоянии ACW
		ROUND(SUM(IRF.TALK_DURATION+IRF.HOLD_DURATION+IRF.AFTER_CALL_WORK_DURATION )/SUM(IRF.TALK_COUNT),2) AS 'AHT, sec'
				
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

			
WHERE (DATE.LABEL_YYYY_MM_DD > '2020-03-25' AND DATE.LABEL_YYYY_MM_DD < '2020-04-26')
 	AND IT.INTERACTION_TYPE='Outbound'
	AND MT.MEDIA_NAME='Voice'
	AND VQ.RESOURCE_NAME<>'VQ_Test_Phone_Inbound'
	AND VQ.RESOURCE_NAME<>'VQ_RU_Phone_Inbound'
	AND (R.RESOURCE_NAME LIKE 'a.belarbi%'
	OR R.RESOURCE_NAME LIKE'j.ngwa%'
	OR R.RESOURCE_NAME LIKE 'a.mutomb%'
	OR R.RESOURCE_NAME LIKE 'k.angelovskiy%'
	OR R.RESOURCE_NAME LIKE 'j.fonjo%'
	OR R.RESOURCE_NAME LIKE 'dp.coloncouo%'
	OR R.RESOURCE_NAME LIKE 'c.veh%'
	OR R.RESOURCE_NAME LIKE 'h.abbadi%')
	
		
GROUP BY DATE.LABEL_YYYY_MM_DD, CAST(DATEADD(hour,3,DATE.CAL_DATE) AS time(1)), VQ.RESOURCE_NAME, R.AGENT_FIRST_NAME, R.AGENT_LAST_NAME, CDI.CUSTOMERLANG

ORDER BY DATE.LABEL_YYYY_MM_DD, CAST(DATEADD(hour,3,DATE.CAL_DATE) AS time(1)), VQ.RESOURCE_NAME