SELECT TOP 1000

IFA.MEDIA_SERVER_IXN_GUID AS [ID]
, DT.LABEL_YYYY_MM_DD_HH24_MI AS [Date]
, CIC.CUSTOMERAWSID AS [AWS ID]
, CIC.CUSTOMEREMAILADDRESS AS [Email Client]
, CIC.CUSTOMERPHONE AS [Phone]


FROM INTERACTION_RESOURCE_FACT IRF

LEFT JOIN INTERACTION_FACT IFA ON IFA.INTERACTION_ID=IRF.INTERACTION_ID

LEFT JOIN DATE_TIME DT ON IRF.START_TS = DT.DATE_TIME_KEY

LEFT JOIN CUST_IRF_CUSTOMER CIC on CIC.INTERACTION_RESOURCE_ID=IRF.INTERACTION_RESOURCE_ID

WHERE 
( CIC.CUSTOMERPHONE <> 'none' OR CIC.CUSTOMEREMAILADDRESS <> 'none')