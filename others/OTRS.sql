SELECT  
COUNT(t.tn)
,u.last_name
,u.first_name

FROM ticket t 

LEFT JOIN users u ON t.user_id = u.id
LEFT JOIN role_user ru ON ru.user_id = u.id
LEFT JOIN roles r ON r.id = ru.role_id
LEFT JOIN service s ON s.id = t.type_id


WHERE

r.name LIKE 'Техники%' OR r.name LIKE 'Techn%'

GROUP BY 
u.last_name
,u.first_name