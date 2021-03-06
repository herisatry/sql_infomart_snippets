SELECT 
    DATE.LABEL_YYYY_MM_DD_HH24_MI AS Date,
	VQ.RESOURCE_NAME AS Language,
	COUNT (DISTINCT IRF.INTERACTION_ID) AS Offered,
	COUNT (DISTINCT CASE WHEN IRF.TALK_COUNT>0 THEN IRF.INTERACTION_ID END) AS Handled,
	COUNT (DISTINCT CASE WHEN TD.TECHNICAL_RESULT IN ('Abandoned','CustomerAbandoned') THEN IRF.INTERACTION_ID END) AS 'Total Abandoned',
	COUNT (DISTINCT CASE WHEN TD.RESULT_REASON IN ('AbandonedWhileQueued', 'AbandonedWhileRinging') THEN IRF.INTERACTION_ID END) AS 'Abandoned (Target)', -- только абандоны с очереди и с холда
	--уточнение по причинам абандонов
	COUNT (DISTINCT CASE WHEN TD.RESULT_REASON = 'AbandonedWhileQueued' THEN IRF.INTERACTION_ID END) AS 'Abandoned Queued',
	COUNT (DISTINCT CASE WHEN TD.RESULT_REASON = 'AbandonedWhileRinging' THEN IRF.INTERACTION_ID END) AS 'Abandoned Ringing',
	COUNT (DISTINCT CASE WHEN TD.RESULT_REASON = 'AbandonedFromHold' THEN IRF.INTERACTION_ID END) AS 'Abandoned Hold',
	CASE WHEN SUM(IRF.TALK_COUNT)>0 THEN ROUND(SUM(IRF.MEDIATION_DURATION)/SUM(IRF.TALK_COUNT),2) ELSE 0 END AS 'AVG Wait Time',
	COUNT (DISTINCT CASE WHEN IRF.TALK_COUNT>0 AND IRF.MEDIATION_DURATION<20 THEN IRF.INTERACTION_ID END) AS 'Handled<20sec',
	COUNT (DISTINCT CASE WHEN IRF.TALK_COUNT>0 AND IRF.MEDIATION_DURATION>=20 AND IRF.MEDIATION_DURATION<=40 THEN IRF.INTERACTION_ID END) AS '20sec<Handled<=40sec',
	COUNT (DISTINCT CASE WHEN IRF.TALK_COUNT>0 AND IRF.MEDIATION_DURATION>40 AND IRF.MEDIATION_DURATION<=60 THEN IRF.INTERACTION_ID END) AS '40sec<Handled<=60sec',
	COUNT (DISTINCT CASE WHEN IRF.TALK_COUNT>0 AND IRF.MEDIATION_DURATION>60 AND IRF.MEDIATION_DURATION<=100 THEN IRF.INTERACTION_ID END) AS '60sec<Handled<=100sec',
	COUNT (DISTINCT CASE WHEN IRF.TALK_COUNT>0 AND IRF.MEDIATION_DURATION>100 THEN IRF.INTERACTION_ID END) AS 'Handled>100sec'
		
				
FROM INTERACTION_RESOURCE_FACT AS IRF
		INNER JOIN INTERACTION_TYPE AS IT ON IRF.INTERACTION_TYPE_KEY=IT.INTERACTION_TYPE_KEY
		INNER JOIN TECHNICAL_DESCRIPTOR AS TD ON IRF.TECHNICAL_DESCRIPTOR_KEY=TD.TECHNICAL_DESCRIPTOR_KEY
		INNER JOIN DATE_TIME AS DATE ON IRF.START_DATE_TIME_KEY=DATE.DATE_TIME_KEY
		LEFT JOIN MEDIA_TYPE AS MT ON IRF.MEDIA_TYPE_KEY=MT.MEDIA_TYPE_KEY
					--присоединяем таблицы для получения страны (очереди ресурса)
		INNER JOIN RESOURCE_ AS R ON IRF.RESOURCE_KEY=R.RESOURCE_KEY
		INNER JOIN RESOURCE_ VQ ON IRF.LAST_VQUEUE_RESOURCE_KEY=VQ.RESOURCE_KEY
		

			
WHERE DATE.LABEL_YYYY_MM >='2019-10'
 	AND IT.INTERACTION_TYPE='Inbound'
	AND MT.MEDIA_NAME='Voice'
	AND VQ.RESOURCE_NAME<>'NONE'
	AND VQ.RESOURCE_NAME<>'VQ_Test_Phone_Inbound'
	AND VQ.RESOURCE_NAME<>'VQ_RU_Phone_Inbound'
		
GROUP BY DATE.LABEL_YYYY_MM_DD_HH24_MI, VQ.RESOURCE_NAME