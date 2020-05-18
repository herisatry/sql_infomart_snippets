SELECT

th.owner_id AS "owner",
th.ticket_id AS "ticket ID",
tlc.start_time AS "Date",
tlc.full_time AS "Duration"


FROM ticket_history th

LEFT JOIN ticket_state ts ON ts.id = th.state_id
LEFT JOIN rs_ticket_life_cycle tlc ON tlc.ticket_id=th.ticket_id

WHERE history_type_id  IN ('27')
AND state_id IN ('10')
AND (tlc.full_time >0)
AND tlc.attribute='StateID'

ORDER BY tlc.start_time

