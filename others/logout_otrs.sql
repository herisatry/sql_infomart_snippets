SELECT
DISTINCT T1."id"
,T1."lastname"
, T1."fistname"
, T1."working area"
,(login.start_time) AS "Login start"
,(login.stop_time) AS "login stop"

FROM

(
SELECT 

DISTINCT (u.id ) AS "id"
,u.last_name AS "lastname"
,u.first_name AS "fistname"
,up.preferences_value AS "working area"


FROM users u

LEFT JOIN role_user ru ON ru.user_id = u.id
LEFT JOIN roles r ON r.id = ru.role_id
LEFT JOIN personal_services ps ON ps.user_id = u.id
LEFT JOIN service s ON s.id = ps.service_id
LEFT JOIN user_preferences up ON up.user_id = u.id AND up.preferences_key ='UserDynamicField_WorkingArea'


WHERE 


r.name LIKE 'Техники%'
) AS T1

LEFT JOIN rs_auto_assign_log AS login ON login.user_id = T1.id AND login."action" = 'login'

where T1."id" = 478

ORDER BY login.start_time