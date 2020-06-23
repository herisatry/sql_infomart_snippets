SELECT * ,
DATEDIFF(minute,T."Дата_начала",T."Дата_окончаня") AS "DATE_DIFF,Min" /* difference between the date when interaction starts and it ends (in minutes)*/

FROM 

(SELECT
R.RESOURCE_NAME AS "ID_AGENT", /*Agent email_id*/
(R.AGENT_LAST_NAME+' '+R.AGENT_FIRST_NAME) AS [Full Name], /*agent fullname*/
INF.MEDIA_SERVER_IXN_GUID AS "Идентификатор_IXN", /* interaction ID */
MT.MEDIA_NAME,
DATEADD(s,INF.START_TS,'19700101') AS "Дата_начала", /*when did they start interacting (client-agent)*/
DATEADD(s,INF.END_TS,'19700101') AS "Дата_окончаня",/*when did they close the interaction with done*/
IRF.HANDLE_COUNT AS "Accepted_Count",
IRF.TALK_COUNT AS "Talk Count", 
FLOOR(IRF.TALK_DURATION/60) AS "Длительность,Min" /*how long did they(the client and the agent) interact in minutes*/

FROM INTERACTION_RESOURCE_FACT IRF
LEFT JOIN TECHNICAL_DESCRIPTOR TD ON TD.TECHNICAL_DESCRIPTOR_KEY=IRF.TECHNICAL_DESCRIPTOR_KEY
LEFT JOIN RESOURCE_ R ON IRF.RESOURCE_KEY = R.RESOURCE_KEY
LEFT JOIN INTERACTION_FACT INF ON INF.INTERACTION_ID = IRF.INTERACTION_ID
LEFT JOIN MEDIA_TYPE MT ON MT.MEDIA_TYPE_KEY=INF.MEDIA_TYPE_KEY

WHERE
IRF.INTERACTION_ID='14102310'AND 
IRF.HANDLE_COUNT = 1) T