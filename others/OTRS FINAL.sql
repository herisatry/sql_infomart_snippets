SELECT
DISTINCT  (t.tn) AS "Tickets"
,T1."id"
,T1."lastname"
, T1."fistname"
, T1."working area"
,MIN(th1.create_time) AS "Creation Date"
,MIN(th2.create_time) AS "progress Date"
,MIN(th3.create_time) AS "answer Date"
,MIN(th4.create_time) AS "resolved Date"
,s.name AS "service"



FROM 

(
SELECT 

DISTINCT

(u.id ) AS "id"
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

LEFT JOIN ticket_history th ON th.owner_id = T1."id"
LEFT JOIN ticket t ON t.id = th.ticket_id
LEFT JOIN service s ON s.id = t.service_id
LEFT JOIN ticket_state ts ON ts.id = th.state_id
LEFT JOIN ticket_history th1 ON th1.ticket_id=t.id AND th1.name = '%%NULL%%%%NULL%%'
LEFT JOIN ticket_history th2 ON th2.ticket_id=t.id AND th2.name = '%%new%%in progress%%'
LEFT JOIN ticket_history th3 ON th3.ticket_id=t.id AND th3.name = '%%in progress%%answer%%'
LEFT JOIN ticket_history th4 ON th4.ticket_id=t.id AND th4.name = '%%answer%%resolved%%'

WHERE t.tn IS NOT NULL 

GROUP BY
t.tn
,T1."id"
,T1."lastname"
, T1."fistname"
, T1."working area"
,ts.name
,th1.create_time
,th2.create_time
,th3.create_time
,th4.create_time
,s.name