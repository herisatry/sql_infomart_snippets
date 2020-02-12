SELECT DATE.LABEL_YYYY_MM_DD AS Date,
cast(DATEADD(hour,2,DATE .CAL_DATE) AS time(0)) AS [Hours],
		VQ.RESOURCE_NAME AS Language,
        R.RESOURCE_NAME AS ID
,R.AGENT_LAST_NAME as "Фамилия"
,R.AGENT_FIRST_NAME as "Имя"
,case when VQ.RESOURCE_NAME<>'NONE' then VQ.RESOURCE_NAME
	  when VQ.RESOURCE_NAME='NONE' and IT.INTERACTION_TYPE='Outbound' then 'Outbound'
      when VQ.RESOURCE_NAME='NONE' and IT.INTERACTION_TYPE='Inbound' then 'Inbound'
	  when VQ.RESOURCE_NAME='NONE' and IT.INTERACTION_TYPE='Internal' then 'Internal'
	  else VQ.RESOURCE_NAME
	  end
as "Скилл"
,count(distinct IRF.INTERACTION_ID) as "Всего звонков" -- Offered calls
,count(distinct case when IT.INTERACTION_TYPE='Inbound' and IRF.TALK_COUNT>0 then IRF.INTERACTION_ID end) as "Принято вх звонков" -- Handled inbound calls



,count(distinct case when TD.TECHNICAL_RESULT='Transferred' then IRF.INTERACTION_ID end) as "Переведенных звонков" -- transferred calls
,count(distinct case when IT.INTERACTION_TYPE='Outbound' and IRF.TALK_COUNT>0 then IRF.INTERACTION_ID end) as "Удачных исх звонков" -- outbound calls
,count(distinct case when IT.INTERACTION_TYPE='Outbound' and IRF.TALK_COUNT=0 then IRF.INTERACTION_ID end) as "Неудачных исх звонков" -- outbound that didnt connect
,case when sum(IRF.TALK_COUNT)>0 then round(sum(IRF.TALK_DURATION)/sum(IRF.TALK_COUNT),2) else 0 end as "Ср. время разговора" -- avg talk time
,case when sum(IRF.HOLD_COUNT)>0 then round(sum(IRF.HOLD_DURATION)/sum(IRF.HOLD_COUNT),2) else 0 end as "Ср. время на холде" -- avg time onhold
,sum(IRF.AFTER_CALL_WORK_DURATION) as "ACW duration"


,case when sum(IRF.TALK_COUNT)>0 then round(sum(IRF.TALK_DURATION)+sum(IRF.HOLD_DURATION)+sum(IRF.AFTER_CALL_WORK_DURATION)/sum(IRF.TALK_COUNT),2) else 0 end as "AHT_voice"
,case when (IT.INTERACTION_TYPE='Outbound' and sum(IRF.TALK_COUNT)>0) then round(sum(IRF.TALK_DURATION)+sum(IRF.HOLD_DURATION)+sum(IRF.AFTER_CALL_WORK_DURATION)/sum(IRF.TALK_COUNT),2) else 0 end as "AHT_voice_outb"
,case when (IT.INTERACTION_TYPE='Inbound' and sum(IRF.TALK_COUNT)>0) then round(sum(IRF.TALK_DURATION)+sum(IRF.HOLD_DURATION)+sum(IRF.AFTER_CALL_WORK_DURATION)/sum(IRF.TALK_COUNT),2) else 0 end as "AHT_voice_inb"

,sum(IRF.TALK_DURATION) as "Длительность разговора"

				
FROM INTERACTION_RESOURCE_FACT AS IRF
		INNER JOIN INTERACTION_TYPE AS IT ON IRF.INTERACTION_TYPE_KEY=IT.INTERACTION_TYPE_KEY
		INNER JOIN TECHNICAL_DESCRIPTOR AS TD ON IRF.TECHNICAL_DESCRIPTOR_KEY=TD.TECHNICAL_DESCRIPTOR_KEY
		INNER JOIN DATE_TIME AS DATE ON IRF.START_DATE_TIME_KEY=DATE.DATE_TIME_KEY
		LEFT JOIN MEDIA_TYPE AS MT ON IRF.MEDIA_TYPE_KEY=MT.MEDIA_TYPE_KEY
					--присоединяем таблицы для получения страны (очереди ресурса)
		INNER JOIN RESOURCE_ AS R ON IRF.RESOURCE_KEY=R.RESOURCE_KEY
		INNER JOIN RESOURCE_ VQ ON IRF.LAST_VQUEUE_RESOURCE_KEY=VQ.RESOURCE_KEY
		

			
WHERE DATE.LABEL_YYYY_MM_DD>='2019-11-01'
	AND MT.MEDIA_NAME='Voice'
	AND VQ.RESOURCE_NAME<>'NONE'
	AND VQ.RESOURCE_NAME<>'VQ_Test_Phone_Inbound'
	AND VQ.RESOURCE_NAME<>'VQ_RU_Phone_Inbound'
		
GROUP BY DATE.LABEL_YYYY_MM_DD, VQ.RESOURCE_NAME,DATE .CAL_DATE , R.RESOURCE_NAME,R.AGENT_LAST_NAME 
,R.AGENT_FIRST_NAME , IT.INTERACTION_TYPE,TD.TECHNICAL_RESULT

ORDER BY DATE.LABEL_YYYY_MM_DD, VQ.RESOURCE_NAME