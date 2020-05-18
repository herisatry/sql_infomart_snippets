SELECT

DT.LABEL_YYYY_MM_DD_HH24_MI AS [Date]
, CIC.CUSTOMERAWSID AS [Client AWS ID]
, CIC.CUSTOMERPHONE AS [Client Phone]
, CIC.CUSTOMEREMAILADDRESS AS [Client Email]

FROM CUST_IRF_CUSTOMER CIC 

LEFT JOIN DATE_TIME DT ON CIC.START_DATE_TIME_KEY = DT.DATE_TIME_KEY

WHERE 
DT.LABEL_YYYY_MM_DD_HH24_MI IS NOT NULL
AND DT.LABEL_YYYY> '2019'
AND NOT CIC.CUSTOMERAWSID  = 'none'
AND NOT CIC.CUSTOMERAWSID = '0'