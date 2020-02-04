DECLARE 
@Media varchar(255)='Voice'

select
DT.LABEL_YYYY_MM_DD AS "Интервал"
,cast(DATEADD(hour,2,DT.CAL_DATE) AS time(0)) AS [Hours]
,R.RESOURCE_NAME AS ID
,R.AGENT_LAST_NAME as "Фамилия"
,R.AGENT_FIRST_NAME as "Имя"
,case when VQ.RESOURCE_NAME<>'NONE' then VQ.RESOURCE_NAME
	  when VQ.RESOURCE_NAME='NONE' and IT.INTERACTION_TYPE='Outbound' then 'Outbound'
	  when VQ.RESOURCE_NAME='NONE' and IT.INTERACTION_TYPE='Internal' then 'Internal'
	  else VQ.RESOURCE_NAME
	  end
as "Скилл"
,count(distinct IRF.INTERACTION_ID) as "Всего звонков"
,count(distinct case when IT.INTERACTION_TYPE='Inbound' and IRF.TALK_COUNT>0 then IRF.INTERACTION_ID end) as "Принято вх звонков"



,count(distinct case when TD.TECHNICAL_RESULT='Transferred' then IRF.INTERACTION_ID end) as "Переведенных звонков"
,count(distinct case when IT.INTERACTION_TYPE='Outbound' and IRF.TALK_COUNT>0 then IRF.INTERACTION_ID end) as "Удачных исх звонков"
,count(distinct case when IT.INTERACTION_TYPE='Outbound' and IRF.TALK_COUNT=0 then IRF.INTERACTION_ID end) as "Неудачных исх звонков"
,case when sum(IRF.TALK_COUNT)>0 then round(sum(IRF.TALK_DURATION)/sum(IRF.TALK_COUNT),2) else 0 end as "Ср. время разговора"
,case when sum(IRF.HOLD_COUNT)>0 then round(sum(IRF.HOLD_DURATION)/sum(IRF.HOLD_COUNT),2) else 0 end as "Ср. время на холде"


,case when sum(IRF.TALK_COUNT)>0 then round(sum(IRF.TALK_DURATION)+sum(IRF.HOLD_DURATION)+sum(IRF.AFTER_CALL_WORK_DURATION)/sum(IRF.TALK_COUNT),2) else 0 end as "AHT_voice"
,case when (IT.INTERACTION_TYPE='Outbound' and sum(IRF.TALK_COUNT)>0) then round(sum(IRF.TALK_DURATION)+sum(IRF.HOLD_DURATION)+sum(IRF.AFTER_CALL_WORK_DURATION)/sum(IRF.TALK_COUNT),2) else 0 end as "AHT_voice_outb"
,case when (IT.INTERACTION_TYPE='Inbound' and sum(IRF.TALK_COUNT)>0) then round(sum(IRF.TALK_DURATION)+sum(IRF.HOLD_DURATION)+sum(IRF.AFTER_CALL_WORK_DURATION)/sum(IRF.TALK_COUNT),2) else 0 end as "AHT_voice_inb"

,sum(IRF.TALK_DURATION) as "Длительность разговора"


from
INFOMART.dbo.INTERACTION_RESOURCE_FACT IRF
left join INFOMART.dbo.TECHNICAL_DESCRIPTOR TD on IRF.TECHNICAL_DESCRIPTOR_KEY=TD.TECHNICAL_DESCRIPTOR_KEY
left join INFOMART.dbo.RESOURCE_ R on IRF.RESOURCE_KEY=R.RESOURCE_KEY
left join INFOMART.dbo.RESOURCE_ VQ on IRF.LAST_VQUEUE_RESOURCE_KEY=VQ.RESOURCE_KEY
left join INFOMART.dbo.DATE_TIME DT on IRF.START_DATE_TIME_KEY=DT.DATE_TIME_KEY
left join INFOMART.dbo.MEDIA_TYPE M on IRF.MEDIA_TYPE_KEY=M.MEDIA_TYPE_KEY
left join INFOMART.dbo.INTERACTION_TYPE IT on IRF.INTERACTION_TYPE_KEY=IT.INTERACTION_TYPE_KEY

where
M.MEDIA_NAME=@Media
and R.RESOURCE_TYPE='Agent'
AND R.AGENT_FIRST_NAME IS NOT NULL
	AND R.AGENT_FIRST_NAME!='%Тест%'
	
	AND NOT R.RESOURCE_NAME IN ('aionov','daniel', 'aamelin')
	AND R.RESOURCE_NAME NOT LIKE '%Test%' AND R.RESOURCE_NAME NOT LIKE '%romanyuta%'
	AND  R.RESOURCE_NAME NOT LIKE '%yazykbaevr%' AND  R.RESOURCE_NAME NOT LIKE '%1000%'
	
		--AND DT.LABEL_YYYY_MM_DD ='2019-11-27' AND R.RESOURCE_NAME LIKE '%b.nkoy%'
group by 
DT.LABEL_YYYY_MM_DD
,DT.CAL_DATE
,R.RESOURCE_NAME
,R.AGENT_LAST_NAME
,R.AGENT_FIRST_NAME
,IT.INTERACTION_TYPE
,case when VQ.RESOURCE_NAME<>'NONE' then VQ.RESOURCE_NAME
	  when VQ.RESOURCE_NAME='NONE' and IT.INTERACTION_TYPE='Outbound' then 'Outbound'
	  when VQ.RESOURCE_NAME='NONE' and IT.INTERACTION_TYPE='Internal' then 'Internal'
	  else VQ.RESOURCE_NAME
	  end