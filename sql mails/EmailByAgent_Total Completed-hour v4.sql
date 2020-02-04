-- DECLARE @DateS varchar(32)='2019-11-18 00:00:00' --��������� ���� ������
-- ,@DateE varchar(32)='2019-11-19 00:00:00' --��������� ���� ���������

select
T1."Language"
,T1.RESOURCE_NAME
,T1.AGENT_LAST_NAME
,T1.AGENT_FIRST_NAME
,T1."���"
,T1."Hours"
,count(distinct T1.INTERACTION_ID) "Accepted"
,sum(case when T1.N_Inb>0 and T1.N_Outb>0 then 1 else 0 end) "Replied"
,sum(T1.N_Inb2) "Processed"
,sum(T1.Transferred) "Transferred"
,sum(T1.N_Initiated) "Initiated"
,sum(T1.[RINGING DURATION]) AS "Ringing Time"
,sum(T1.[TALK DURATION]) AS "Talking Time"
from
(select
DI.CUSTOMERLANG as "Language"
,R2.RESOURCE_NAME RESOURCE_NAME
,R2.AGENT_LAST_NAME AGENT_LAST_NAME
,R2.AGENT_FIRST_NAME AGENT_FIRST_NAME
,DT.LABEL_YYYY_MM_DD as "���"
,cast(DATEADD(hour,2,DT.CAL_DATE) AS time(0)) AS "Hours"
,IRF.INTERACTION_ID INTERACTION_ID
,count(distinct case when IT.INTERACTION_TYPE='Inbound' and R.RESOURCE_NAME='BasicEmailInbound.default.EmailInboundContactProcessed' then IRF.INTERACTION_ID end) as N_Inb
,count(distinct case when IT.INTERACTION_TYPE='Outbound' and R.RESOURCE_NAME='BasicEmailInbound.default.EmailOutgoing' then IRF.INTERACTION_ID end) as N_Outb
,count(distinct case when IT.INTERACTION_TYPE='Inbound' and R.RESOURCE_NAME='BasicEmailInbound.default.EmailInboundContactProcessed' and TD2.TECHNICAL_RESULT in ('Completed','Transferred') then IRF.INTERACTION_ID end) as N_Inb2
,count(distinct case when IT.INTERACTION_TYPE='Inbound' and R.RESOURCE_NAME='BasicEmailInbound.default.EmailInboundContactProcessed' and TD2.TECHNICAL_RESULT in ('Transferred') then IRF.INTERACTION_ID end) as Transferred
,COUNT(DISTINCT CASE WHEN IRF.HANDLE_COUNT <> 0 AND IT.INTERACTION_SUBTYPE_CODE = 'OUTBOUNDNEW' then IRF.INTERACTION_ID end) AS N_Initiated
,IRF.RING_DURATION AS [RINGING DURATION]
, IRF.TALK_DURATION AS [TALK DURATION]
from
INFOMART.dbo.MEDIATION_SEGMENT_FACT MSF
left join INFOMART.dbo.INTERACTION_RESOURCE_FACT IRF on MSF.INTERACTION_ID=IRF.INTERACTION_ID
left join INFOMART.dbo.DATE_TIME DT on IRF.START_DATE_TIME_KEY=DT.DATE_TIME_KEY
left join INFOMART.dbo.TECHNICAL_DESCRIPTOR TD2 on IRF.TECHNICAL_DESCRIPTOR_KEY=TD2.TECHNICAL_DESCRIPTOR_KEY
left join INFOMART.dbo.RESOURCE_ R on MSF.RESOURCE_KEY=R.RESOURCE_KEY
left join INFOMART.dbo.RESOURCE_ R2 on IRF.RESOURCE_KEY=R2.RESOURCE_KEY
left join INFOMART.dbo.MEDIA_TYPE M on MSF.MEDIA_TYPE_KEY=M.MEDIA_TYPE_KEY
left join INFOMART.dbo.INTERACTION_TYPE IT on IRF.INTERACTION_TYPE_KEY=IT.INTERACTION_TYPE_KEY
left join INFOMART.dbo.IRF_USER_DATA_KEYS UK on IRF.INTERACTION_RESOURCE_ID=UK.INTERACTION_RESOURCE_ID
left join INFOMART.dbo.CUST_DIM_INTERACTION DI on UK.CUST_DIM_INTERACTION=DI.ID			 
where
-- IRF.START_DATE_TIME_KEY>=DATEDIFF(s,'1970-01-01 00:00:00',@DateS) and IRF.START_DATE_TIME_KEY<DATEDIFF(s,'1970-01-01 00:00:00',@DateE) 
-- and 
MSF.START_DATE_TIME_KEY >= IRF.START_DATE_TIME_KEY-2592000  -- 2592000 = Sat Jan 31 00:00:00 1970 UTC. Unix Timestamp
and MSF.MEDIA_TYPE_KEY=2
and R2.RESOURCE_TYPE='Agent'
AND NOT R2.RESOURCE_NAME IN ('aionov','daniel', 'aamelin')
AND R2.RESOURCE_NAME NOT LIKE '%Test%' AND R2.RESOURCE_NAME NOT LIKE '%romanyuta%'
AND  R2.RESOURCE_NAME NOT LIKE '%yazykbaevr%' AND  R2.RESOURCE_NAME NOT LIKE '%1000%'

group by
DT.LABEL_YYYY_MM_DD
,DI.CUSTOMERLANG
,R2.RESOURCE_NAME
,R2.AGENT_LAST_NAME
,R2.AGENT_FIRST_NAME
,IRF.INTERACTION_ID
,IRF.RING_DURATION
, IRF.TALK_DURATION
,DT.CAL_DATE
) as T1
group by
T1."Language"
,T1.RESOURCE_NAME
,T1.AGENT_LAST_NAME
,T1.AGENT_FIRST_NAME
,T1."���"
,T1."Hours"
order by 
T1."Language"
,T1.RESOURCE_NAME
,T1."���"
