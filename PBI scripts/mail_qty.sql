SELECT COUNT(t.tn) ,
t.create_time
FROM ticket t
LEFT JOIN service s ON s.id = t.service_id

WHERE s.name LIKE '%Technicians::%'

GROUP BY t.create_time