SELECT
DISTINCT (t.tn) AS "Tickets"
,(th1.create_time) AS "Creation Date"
,(th2.create_time) AS "progress Date"
,(th3.create_time) AS "answer Date"
,s.name AS "service"



FROM ticket_history th

LEFT JOIN ticket t ON t.id = th.ticket_id
LEFT JOIN service s ON s.id = t.service_id
LEFT JOIN ticket_state ts ON ts.id = th.state_id
LEFT JOIN ticket_history th1 ON th1.ticket_id=t.id AND th1.name = '%%NULL%%%%NULL%%'
LEFT JOIN ticket_history th2 ON th2.ticket_id=t.id AND th2.name = '%%new%%in progress%%'
LEFT JOIN ticket_history th3 ON th3.ticket_id=t.id AND th3.name = '%%in progress%%answer%%'

WHERE t.tn IS NOT NULL 

GROUP BY
t.tn
,ts.name
,th1.create_time
,th2.create_time
,th3.create_time
,s.name