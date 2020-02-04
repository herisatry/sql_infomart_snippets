SET ARITHABORT OFF
SET ANSI_WARNINGS OFF

SELECT
R.RESOURCE_NAME, DT.LABEL_YYYY_MM_DD, DT.LABEL_HH24,DT.LABEL_MI,

COUNT( DISTINCT CASE WHEN IRF.HANDLE_COUNT <> 0 AND IT.INTERACTION_TYPE = 'Outbound' THEN IRF.INTERACTION_ID END ) AS [# Outbound ],
COUNT(   DISTINCT CASE WHEN IRF.TALK_COUNT>0 AND IRF.HANDLE_COUNT <> 0 AND IT.INTERACTION_TYPE = 'Outbound' AND IRF.TALK_COUNT>0 THEN IRF.INTERACTION_ID END ) AS [Connected Outbound],
CASE WHEN (IRF.HANDLE_COUNT <> 0 AND IT.INTERACTION_TYPE = 'Outbound' THEN (IRF.TALK_DURATION) END ) AS [talk time not connected],
CASE WHEN (IRF.TALK_COUNT>0 AND IRF.HANDLE_COUNT <> 0 AND IT.INTERACTION_TYPE = 'Outbound' AND IRF.TALK_COUNT>0  THEN (IRF.TALK_DURATION) END ) AS [talk time connected],

--COUNT( DISTINCT CASE WHEN IRF.HANDLE_COUNT <> 0 AND IT.INTERACTION_TYPE = 'Inbound' THEN IRF.INTERACTION_ID END ) AS [# Inbound],

--COUNT (DISTINCT CASE WHEN TD.TECHNICAL_RESULT='Transferred' THEN IRF.INTERACTION_ID END) AS [Transfered], --кол-во переведенных звонков
		/* Mediation Duration (cчитаем как ASA)- Истекшее время в секундах, в течение которого взаимодействие с клиентом проводилось в посредничестве
		(в очередях, точках маршрутизации или IVR, не связанных с самообслуживанием) до достижения ресурса, представленного строкой IRF.
		Это время измеряется от времени начала передачи IRF до момента, когда взаимодействие достигает ресурса, представленного строкой IRF*/
		--sum(IRF.TALK_DURATION) AS [talk time]
		---ROUND(SUM(IRF.TALK_DURATION)/SUM(IRF.TALK_COUNT),2)  AS 'AVG Talk Time, sec',--количество секунд, которое IVR самообслуживания или ресурс агента потратил на разговор по этому голосовому взаимодействию.
	--ROUND(SUM(IRF.RING_DURATION)/SUM(IRF.TALK_COUNT),2)  AS 'AVG Ring Dutation, sec',--количество секунд, в течение которых голосовое взаимодействие звонило на IVR самообслуживания или ресурсе агента
		--ROUND(SUM(IRF.HOLD_DURATION)/SUM(IRF.TALK_COUNT),2)  AS 'AVG Hold Time, sec',--количество секунд, в течение которых ресурс, связанный с этим голосовым взаимодействием, переводил взаимодействие в режим удержания
		--CASE WHEN SUM(IRF.AFTER_CALL_WORK_COUNT)>0 THEN ROUND(SUM(IRF.AFTER_CALL_WORK_DURATION)/SUM(IRF.TALK_COUNT),2) ELSE '' END AS 'AVG After Call Work Time, sec',--Количество секунд, в течение которых ресурс IRF, связанный с этим голосовым взаимодействием, находился в состоянии ACW
--	ROUND(SUM(IRF.TALK_DURATION+IRF.HOLD_DURATION+IRF.AFTER_CALL_WORK_DURATION )/SUM(IRF.TALK_COUNT),2) AS 'AHT, sec'


FROM INTERACTION_RESOURCE_FACT IRF

INNER JOIN MEDIA_TYPE MT ON IRF.MEDIA_TYPE_KEY = MT.MEDIA_TYPE_KEY
INNER JOIN DATE_TIME DT ON IRF.START_DATE_TIME_KEY = DT.DATE_TIME_KEY
INNER JOIN RESOURCE_ R ON IRF.RESOURCE_KEY = R.RESOURCE_KEY
INNER JOIN INTERACTION_TYPE IT ON IRF.INTERACTION_TYPE_KEY = IT.INTERACTION_TYPE_KEY

INNER JOIN TECHNICAL_DESCRIPTOR AS TD ON IRF.TECHNICAL_DESCRIPTOR_KEY=TD.TECHNICAL_DESCRIPTOR_KEY

--присоединение внешних таблиц для получения страны из CUST_DIM_Interaction
		LEFT JOIN IRF_USER_DATA_KEYS AS UDK ON IRF.INTERACTION_RESOURCE_ID=UDK.INTERACTION_RESOURCE_ID
		LEFT JOIN CUST_DIM_INTERACTION AS CDI ON UDK.CUST_DIM_INTERACTION=CDI.ID

WHERE 

NOT R.RESOURCE_NAME IN ('aionov','daniel', 'aamelin')
AND R.RESOURCE_NAME NOT LIKE '%Test%' AND R.RESOURCE_NAME NOT LIKE '%romanyuta%'
AND  R.RESOURCE_NAME NOT LIKE '%yazykbaevr%' AND  R.RESOURCE_NAME NOT LIKE '%1000%'

AND R.RESOURCE_NAME LIKE '%b.nkoy%' AND DT.LABEL_YYYY_MM_DD = '2019-11-27'

AND MT.MEDIA_NAME = 'Voice'
AND R.RESOURCE_NAME<>'VQ_Test_Phone_Inbound'
AND R.RESOURCE_NAME<>'VQ_RU_Phone_Inbound'



GROUP BY R.RESOURCE_NAME, DT.LABEL_YYYY_MM_DD,DT.LABEL_HH24,DT.LABEL_MI
ORDER BY DT.LABEL_YYYY_MM_DD, DT.LABEL_HH24
