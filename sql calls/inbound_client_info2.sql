SELECT  
COUNT(DISTINCT CASE WHEN G_SUB_TYPE='InboundNew' OR G_SUB_TYPE='InboundCustomerReply' THEN  US.CALLID END ) AS [# Of Emails]
,COUNT(DISTINCT CASE WHEN G_SUB_TYPE='InboundNew' OR G_SUB_TYPE='InboundCustomerReply' THEN  US.G_FROM_ADDRESS END ) AS [# Distinct clients]
--,cast(US.G_RECEIVED_D AS date) AS date


FROM GIDB_GM_F_USERDATA US

WHERE
cast(US.G_RECEIVED_D AS date)='2020-01-09'