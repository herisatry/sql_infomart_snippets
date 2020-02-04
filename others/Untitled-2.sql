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
,sum(IRF.TALK_DURATION) as "Длительность разговора"
,'' as "Длительность онлайн"
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
,case when VQ.RESOURCE_NAME<>'NONE' then VQ.RESOURCE_NAME
	  when VQ.RESOURCE_NAME='NONE' and IT.INTERACTION_TYPE='Outbound' then 'Outbound'
	  when VQ.RESOURCE_NAME='NONE' and IT.INTERACTION_TYPE='Internal' then 'Internal'
	  else VQ.RESOURCE_NAME
	  end

union

select
DT.LABEL_YYYY_MM_DD AS "Интервал"
,cast(DATEADD(hour,2,DT.CAL_DATE) AS time(0)) AS offset_Time AS [Hours]
,R.RESOURCE_NAME AS ID
,R.AGENT_LAST_NAME as "Фамилия"
,R.AGENT_FIRST_NAME as "Имя"
,'' as "Скилл"
,'' as "Всего звонков"
,'' AS "Принято вх звонков"
,'' as "Переведенных звонков"
,'' as "Удачных исх звонков"
,'' as "Неудачных исх звонков"
,'' as "Ср. время разговора"
,'' as "Ср. время на холде"
,'' as "Длительность разговора"
,sum(case when RS.STATE_NAME='Busy' then SF.TOTAL_DURATION else 0 end)+sum(case when RS.STATE_NAME='AfterCallWork' then SF.TOTAL_DURATION else 0 end)+sum(case when RS.STATE_NAME='Ready' then SF.TOTAL_DURATION else 0 end)+sum(case when RS.STATE_NAME='NotReady' then SF.TOTAL_DURATION else 0 end)+sum(case when RS.STATE_NAME='LoggedOnOnly' then SF.TOTAL_DURATION else 0 end)  as "Длительность онлайн"
from
INFOMART.dbo.SM_RES_STATE_FACT SF
left join INFOMART.dbo.RESOURCE_ R on SF.RESOURCE_KEY=R.RESOURCE_KEY
left join INFOMART.dbo.DATE_TIME DT on SF.START_DATE_TIME_KEY=DT.DATE_TIME_KEY
left join INFOMART.dbo.MEDIA_TYPE M on SF.MEDIA_TYPE_KEY=M.MEDIA_TYPE_KEY
left join INFOMART.dbo.RESOURCE_STATE RS on SF.RESOURCE_STATE_KEY=RS.RESOURCE_STATE_KEY
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

order by 1,2,3

