SELECT th.ticket_id, CASE WHEN th.create_by = 1 THEN th.owner_id ELSE th.create_by END, th.state_id, th.create_time , ts.name
FROM ticket_history th
LEFT JOIN ticket_state ts ON ts.id = th.state_id
WHERE 
ticket_id = '295' 
AND history_type_id  = '27'
AND state_id IN ('4', '10')
ORDER BY create_time