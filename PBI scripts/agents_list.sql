SELECT
distinct R.RESOURCE_NAME AS Email_ID, (R.AGENT_LAST_NAME+' ' +R.AGENT_FIRST_NAME) AS FullName

FROM RESOURCE_ R

WHERE R.RESOURCE_TYPE = 'Agent'
AND NOT R.RESOURCE_NAME IN ('aionov','daniel', 'aamelin')
AND R.RESOURCE_NAME NOT LIKE '%Test%' AND R.RESOURCE_NAME NOT LIKE '%romanyuta%' AND  R.RESOURCE_NAME NOT LIKE '%yazykbaevr%' /* S.SKILL_NAME LIKE '__'  , two characters */

GROUP BY R.RESOURCE_NAME, R.AGENT_FIRST_NAME, R.AGENT_LAST_NAME, R.AGENT_NAME, R.EMPLOYEE_ID