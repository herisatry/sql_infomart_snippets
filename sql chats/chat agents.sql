DECLARE 
@Date varchar(32)='2019-11-12'
,@Media varchar(255)='Chat'

select
DT.LABEL_YYYY_MM_DD_HH24 as "Date"
,R.AGENT_LAST_NAME AS "Last Name"
,R.AGENT_FIRST_NAME as "First Name"
,R.RESOURCE_NAME
,M.MEDIA_NAME
,DI.CUSTOMERLANG as Lang
,count(distinct case when CSF.AGENTS_COUNT>0 then CSF.MEDIA_SERVER_IXN_GUID end) as "Total # of chats"
,count(distinct case when TD2.RESULT_REASON in ('AbandonedWhileRinging','AbandonedFromHold') then CSF.MEDIA_SERVER_IXN_GUID end) as "# of unanswered/timed out chats"
,count(distinct case when TD2.TECHNICAL_RESULT in ('Transferred') then CSF.MEDIA_SERVER_IXN_GUID end) as "# of Transferred chats"
,case when sum(CSF.AGENT_REPLY_COUNT)>0 then sum(CSF.AGENT_REPLY_DURATION)/sum(CSF.AGENT_REPLY_COUNT) else '' end as "Avg Response Time" --агента
,case when count(case when CSF.AGENTS_COUNT>0 then CSF.MEDIA_SERVER_IXN_GUID end)>0 then sum(case when CSF.UNTIL_FIRST_REPLY_DURATION>0 then CSF.UNTIL_FIRST_REPLY_DURATION-CSF.UNTIL_FIRST_AGENT_DURATION else '' end)/count(case when CSF.AGENTS_COUNT>0 then CSF.MEDIA_SERVER_IXN_GUID end) else '' end as "Avg First Response Time" --агентом после присоединения к сессии
,case when count(CSF.MEDIA_SERVER_IXN_GUID)>0 then sum(CSF.SESSION_DURATION-CSF.UNTIL_FIRST_AGENT_DURATION)/count(CSF.MEDIA_SERVER_IXN_GUID) else '' end as "Avg Chat Handling Time" -- с момента присоединения агента
,case when count(CSF.MEDIA_SERVER_IXN_GUID)>0 then sum(CSF.SESSION_DURATION-CSF.UNTIL_FIRST_AGENT_DURATION) else '' end as "Chat Duration"
,case when count(case when TD2.RESULT_REASON in ('AbandonedWhileRinging','AbandonedFromHold') then CSF.MEDIA_SERVER_IXN_GUID end)>0 then sum(case when TD2.RESULT_REASON in ('AbandonedWhileRinging','AbandonedFromHold') then CSF.SESSION_DURATION-CSF.UNTIL_FIRST_AGENT_DURATION end)/count(case when TD2.RESULT_REASON in ('AbandonedWhileRinging','AbandonedFromHold') then CSF.MEDIA_SERVER_IXN_GUID end) else '' end as "Avg Abandoned Time HHMMSS" -- с момента присоединения агента

from
INFOMART.dbo.MEDIATION_SEGMENT_FACT MSF
left join INFOMART.dbo.INTERACTION_RESOURCE_FACT IRF on MSF.TARGET_IXN_RESOURCE_ID=IRF.INTERACTION_RESOURCE_ID
left join INFOMART.dbo.TECHNICAL_DESCRIPTOR TD on MSF.TECHNICAL_DESCRIPTOR_KEY=TD.TECHNICAL_DESCRIPTOR_KEY
left join INFOMART.dbo.TECHNICAL_DESCRIPTOR TD2 on IRF.TECHNICAL_DESCRIPTOR_KEY=TD2.TECHNICAL_DESCRIPTOR_KEY
left join INFOMART.dbo.RESOURCE_ VQ on MSF.RESOURCE_KEY=VQ.RESOURCE_KEY
left join INFOMART.dbo.RESOURCE_ R on IRF.RESOURCE_KEY=R.RESOURCE_KEY
left join INFOMART.dbo.MEDIA_TYPE M on MSF.MEDIA_TYPE_KEY=M.MEDIA_TYPE_KEY
left join INFOMART.dbo.CHAT_SESSION_FACT CSF on MSF.MEDIA_SERVER_IXN_GUID=CSF.MEDIA_SERVER_IXN_GUID
left join INFOMART.dbo.DATE_TIME DT on MSF.START_DATE_TIME_KEY=DT.DATE_TIME_KEY
left join INFOMART.dbo.IRF_USER_DATA_KEYS UK on IRF.INTERACTION_RESOURCE_ID=UK.INTERACTION_RESOURCE_ID
left join INFOMART.dbo.CUST_DIM_SURVAY DS on UK.CUST_DIM_SURVAY=DS.ID
left join INFOMART.dbo.CUST_DIM_INTERACTION DI on UK.CUST_DIM_INTERACTION=DI.ID
where
M.MEDIA_NAME=@Media
AND NOT R.RESOURCE_NAME IN ('aionov','daniel', 'aamelin')
AND R.RESOURCE_NAME NOT LIKE '%Test%' AND R.RESOURCE_NAME NOT LIKE '%romanyuta%'
AND R.RESOURCE_NAME NOT LIKE '%yazykbaevr%' AND  R.RESOURCE_NAME NOT LIKE '%1000%'
AND DI.CUSTOMERLANG NOT LIKE 'none'
AND R.RESOURCE_TYPE='Agent'
group by 
DT.LABEL_YYYY_MM_DD_HH24  
,R.AGENT_LAST_NAME  
,R.AGENT_FIRST_NAME
,R.RESOURCE_NAME  
,DI.CUSTOMERLANG
,M.MEDIA_NAME
order by 1,2,3,4