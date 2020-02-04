SELECT DATE.LABEL_YYYY_MM_DD AS Date,
			cast(DATEADD(hour,2,DATE .CAL_DATE) AS time(0)) AS Hours,
			R.RESOURCE_NAME AS ID, (R.AGENT_FIRST_NAME+' '+ R.AGENT_LAST_NAME) as FullName,VQ.RESOURCE_NAME AS Language,


			-- Outbound section START --


count(distinct case when IRF.TALK_COUNT>0 and IT.INTERACTION_TYPE='Outbound' then IRF.INTERACTION_ID end) as [Outbound calls] -- outbound calls
,count(distinct case when IRF.TALK_COUNT=0 and IT.INTERACTION_TYPE='Outbound' then IRF.INTERACTION_ID end) as [Outbound calls not connected] -- outbound that didnt connect

		,COUNT (DISTINCT CASE WHEN TD.TECHNICAL_RESULT='Transferred' THEN IRF.INTERACTION_ID END) AS [Transferred]
		,case when SUM(IRF.TALK_COUNT)>0 and IT.INTERACTION_TYPE='Outbound' then ROUND(SUM(IRF.TALK_DURATION)/SUM(IRF.TALK_COUNT),2) ELSE '' end AS [AVG outb Talk Time],
		case when SUM(IRF.TALK_COUNT)>0 and IT.INTERACTION_TYPE='Outbound' then ROUND(SUM(IRF.RING_DURATION)/SUM(IRF.TALK_COUNT),2) ELSE '' end AS [AVG outb Ring Dutation],
		case when SUM(IRF.TALK_COUNT)>0 and IT.INTERACTION_TYPE='Outbound' then ROUND(SUM(IRF.HOLD_DURATION)/SUM(IRF.TALK_COUNT),2) ELSE '' end AS [AVG outb Hold Time],
		CASE WHEN SUM(IRF.AFTER_CALL_WORK_COUNT)>0 and SUM(IRF.TALK_COUNT)>0 and IT.INTERACTION_TYPE='Outbound' then ROUND(SUM(IRF.AFTER_CALL_WORK_DURATION)/SUM(IRF.TALK_COUNT),2) ELSE '' END AS [AVG outb After Call Work Time]
		,case when SUM(IRF.TALK_COUNT)>0 and IT.INTERACTION_TYPE='Outbound' then ROUND(SUM(IRF.TALK_DURATION+IRF.HOLD_DURATION+IRF.AFTER_CALL_WORK_DURATION )/SUM(IRF.TALK_COUNT),2) ELSE '' end AS [AHT Outbound]


		-- Outbound section END --

		-- inbound sections START --

		,count(distinct case when IRF.TALK_COUNT>0 and IT.INTERACTION_TYPE='Inbound' then IRF.INTERACTION_ID end) as [Inbound calls],
		
		case when sum(IRF.TALK_COUNT)>0 and IT.INTERACTION_TYPE='Inbound' then ROUND(SUM(IRF.TALK_DURATION)/SUM(IRF.TALK_COUNT),2) ELSE '' end AS [AVG Inb Talk Time],
		case when sum(IRF.TALK_COUNT)>0 and IT.INTERACTION_TYPE='Inbound' then ROUND(SUM(IRF.RING_DURATION)/SUM(IRF.TALK_COUNT),2) ELSE '' end AS [AVG Inb Ring Dutation],
		case when sum(IRF.TALK_COUNT)>0 and IT.INTERACTION_TYPE='Inbound' then ROUND(SUM(IRF.HOLD_DURATION)/SUM(IRF.TALK_COUNT),2) ELSE '' end AS [AVG Inb Hold Time],
		CASE WHEN SUM(IRF.AFTER_CALL_WORK_COUNT)>0 and IT.INTERACTION_TYPE='Inbound' THEN ROUND(SUM(IRF.AFTER_CALL_WORK_DURATION)/SUM(IRF.TALK_COUNT),2) ELSE '' END AS [AVG Inb After Call Work Time],
		case when sum(IRF.TALK_COUNT)>0 and IT.INTERACTION_TYPE='Inbound' then round(sum(IRF.TALK_DURATION)+sum(IRF.HOLD_DURATION)+sum(IRF.AFTER_CALL_WORK_DURATION)/sum(IRF.TALK_COUNT),2) ELSE '' end as [AHT Inbound]


		-- inbound sections END --



				
FROM INTERACTION_RESOURCE_FACT AS IRF
		INNER JOIN INTERACTION_TYPE AS IT ON IRF.INTERACTION_TYPE_KEY=IT.INTERACTION_TYPE_KEY
		INNER JOIN TECHNICAL_DESCRIPTOR AS TD ON IRF.TECHNICAL_DESCRIPTOR_KEY=TD.TECHNICAL_DESCRIPTOR_KEY
		INNER JOIN DATE_TIME AS DATE ON IRF.START_DATE_TIME_KEY=DATE.DATE_TIME_KEY
		LEFT JOIN MEDIA_TYPE AS MT ON IRF.MEDIA_TYPE_KEY=MT.MEDIA_TYPE_KEY

		INNER JOIN RESOURCE_ AS R ON IRF.RESOURCE_KEY=R.RESOURCE_KEY
		INNER JOIN RESOURCE_ VQ ON IRF.LAST_VQUEUE_RESOURCE_KEY=VQ.RESOURCE_KEY

		LEFT JOIN IRF_USER_DATA_KEYS AS UDK ON IRF.INTERACTION_RESOURCE_ID=UDK.INTERACTION_RESOURCE_ID
		LEFT JOIN CUST_DIM_INTERACTION AS CDI ON UDK.CUST_DIM_INTERACTION=CDI.ID

			
WHERE IRF.TALK_COUNT>0
 	-- AND IT.INTERACTION_TYPE='Outbound'
	AND MT.MEDIA_NAME='Voice'
	AND VQ.RESOURCE_NAME<>'VQ_Test_Phone_Inbound'
	AND VQ.RESOURCE_NAME<>'VQ_RU_Phone_Inbound'
	AND R.AGENT_FIRST_NAME IS NOT NULL
	AND R.AGENT_FIRST_NAME!='%Тест%'
	
	AND NOT R.RESOURCE_NAME IN ('aionov','daniel', 'aamelin')
	AND R.RESOURCE_NAME NOT LIKE '%Test%' AND R.RESOURCE_NAME NOT LIKE '%romanyuta%'
	AND  R.RESOURCE_NAME NOT LIKE '%yazykbaevr%' AND  R.RESOURCE_NAME NOT LIKE '%1000%'
	
		
GROUP BY DATE.LABEL_YYYY_MM_DD, DATE.CAL_DATE, R.RESOURCE_NAME, R.AGENT_FIRST_NAME, R.AGENT_LAST_NAME,IT.INTERACTION_TYPE