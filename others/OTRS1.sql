SELECT
T1."lastname"
, T1."fistname"
, (t.tn) AS "Tickets"
,CASE WHEN ts.name = 'new' THEN th.create_time END AS "Creation Date"
,CASE WHEN ts.name = 'in progress' THEN th.create_time END AS "progress Date"
,CASE WHEN ts.name = 'answer' THEN th.create_time ELSE NULL END AS "answer Date"
,CASE WHEN ts.name = 'resolved' THEN th.create_time ELSE NULL END AS "resolve Date"
,CASE WHEN ts.name = 'closed' THEN th.create_time ELSE NULL END AS "closed Date"
-- ,t.tn
,s.name AS "service"



FROM 

(SELECT 

DISTINCT (u.id ) AS "id"
,u.last_name AS "lastname"
,u.first_name AS "fistname"

FROM users u

LEFT JOIN role_user ru ON ru.user_id = u.id
LEFT JOIN roles r ON r.id = ru.role_id
LEFT JOIN personal_services ps ON ps.user_id = u.id
LEFT JOIN service s ON s.id = ps.service_id


WHERE 

r.name LIKE 'Техники%'

) AS T1

LEFT JOIN ticket_history th ON th.owner_id = T1."id"
LEFT JOIN ticket t ON t.id = th.ticket_id
LEFT JOIN service s ON s.id = t.service_id
LEFT JOIN ticket_state ts ON ts.id = th.state_id


GROUP BY
t.tn
,T1."lastname"
, T1."fistname"
,ts.name
,th.create_time
,s.name

ORDER BY 1