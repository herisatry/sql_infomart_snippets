SELECT

tlc.id as "Life Cycle ID",
t.id AS "ticket ID",
t.tn as "Ticket Nr",
tlc.start_time,
tlc.end_time,
tlc.full_time AS "Duration",
t.service_id AS "service id",
T1."lastname",
T1."firstname"



FROM 
(
SELECT 

DISTINCT

(u.id ) AS "id"
,u.last_name AS "lastname"
,u.first_name AS "firstname"
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
left join rs_ticket_life_cycle tlc ON th.ticket_id=tlc.ticket_id
LEFT JOIN ticket t ON t.id = th.ticket_id

where -- start_time > '2020-04-14 23:59:59'
--tn='50388676'AND 
tlc.attribute='StateID'
AND tlc.start_time != tlc.end_time
AND tlc.attribute_id=1
AND t.queue_id=129


GROUP BY tlc.id, t.tn,t.id ,T1."lastname",
T1."firstname"
ORDER BY start_time ASC



