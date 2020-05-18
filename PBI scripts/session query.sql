-- tickets processing time without tickets with wrong state changes (answer -> in progress)
SELECT ff.tn
,ff.agent
,ff.services
,ff.service_id
,ff.my_state_id
,ff.my_state_name
,(ff.create_time)::date
, SUM(ff.dt_next_diff_sec) AS s_proc_time_sec
, ROUND((SUM(ff.dt_next_diff_sec)/60):: NUMERIC,1) AS s_proc_time_minut
, ROUND((SUM(ff.dt_next_diff_sec)/3600):: NUMERIC,1) AS s_proc_time_hour
FROM (
SELECT kk.ticket_id
		,kk.tn
		,kk.services
		,kk.service_id
		,kk.agent
		,kk.action_name
		,kk.create_time
		,kk.next_dt
		,kk.dt_next_diff_sec
		,kk.state_name
		, CASE WHEN th3.my_state IS NULL THEN kk.state_name ELSE th3.my_state END AS my_state_name
		, CASE WHEN th3.my_state = 'answer' THEN 10 WHEN th3.my_state = 'new' THEN 1 ELSE kk.state_id END AS my_state_id
FROM (
SELECT mm.ticket_id
			,mm.tn
			,mm.create_time
			,lead(mm.create_time,1) over (PARTITION BY mm.ticket_id) AS next_dt
			, EXTRACT(EPOCH
FROM (lead(mm.create_time,1,mm.create_time) over (PARTITION BY mm.ticket_id)) - mm."tcreation_time") AS dt_next_diff_sec
			,mm.agent
			,mm.action_name
			,mm.state_id
			,mm.state_name
			,mm.services
			,mm.service_id
FROM (
SELECT th.ticket_id
					,t.tn
					,s.name AS services
					,s.id AS service_id
					,th.create_time
                    ,t.create_time as "tcreation_time"
					 --,th.create_by
					,
CONCAT(u.first_name,' ',u.last_name) AS agent
					 --,th.id
					,th.name
AS action_name 
					 --,th.queue_id 
					 --,q.name as responsible_tech
					,th.state_id
					,ts.name
AS state_name
FROM ticket_history th
LEFT JOIN ticket t ON th.ticket_id = t.id
LEFT JOIN service s ON s.id=t.service_id
LEFT JOIN users u ON th.create_by = u.id
LEFT JOIN queue q ON th.queue_id = q.id
LEFT JOIN ticket_state ts ON th.state_id = ts.id
LEFT JOIN (
SELECT DISTINCT the.ticket_id,the.owner_id
FROM ticket_history the
WHERE the.name = '%%answer%%in progress%%'
					) ee -- tickets with error state
ON th.ticket_id = ee.ticket_id
WHERE ee.ticket_id IS NULL
ORDER BY th.ticket_id
					,th.create_time 
					,th.id
			) mm
		) kk
LEFT JOIN (
SELECT DISTINCT th2.ticket_id
		,th2.create_time
		,th2.owner_id
		, CASE WHEN th2.name = '%%in progress%%answer%%' THEN 'answer'
		WHEN th2.name = '%%answer%%new%%' THEN 'new' ELSE 'e' END AS my_state
FROM ticket_history th2
WHERE (CASE WHEN th2.name = '%%in progress%%answer%%' THEN 'answer' WHEN th2.name = '%%answer%%new%%' THEN 'new' ELSE 'e' END) != 'e' 
		) th3 -- data for update
ON kk.ticket_id = th3.ticket_id AND kk.create_time = th3.create_time
) ff
WHERE ff.my_state_name in ('new', 'in progress', 'answer')
GROUP BY (ff.create_time)::date, ff.tn
,ff.my_state_id
,ff.service_id
,ff.agent
,ff.my_state_name
,ff.services


LIMIT 100