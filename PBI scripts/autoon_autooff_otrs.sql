SELECT mm.id,
(mm.previous_login)::date,
SUM(mm.duration_sec)
,round((sum(mm.duration_sec)/60)::numeric,1) as duration_minut
,round((sum(mm.duration_sec)/3600)::numeric,1) as duration_hour

FROM
(
SELECT * ,
case WHEN (kk.previous_login)::DATE = (kk.last_login)::DATE THEN EXTRACT('EPOCH' FROM kk.previous_login) - EXTRACT('EPOCH' FROM kk.last_login) END AS duration_sec
-- CASE WHEN (EXTRACT('EPOCH' FROM previous_login) - EXTRACT('EPOCH' FROM last_login) >= 15*60*60 ) OR 
-- last_login IS NULL THEN 1 ELSE 0 END AS is_new_session

FROM (
SELECT 
AS1.user_id AS id,
AS1.start_time AS  previous_login,
LAG(AS1.start_time)
	OVER (PARTITION BY AS1.user_id,(AS1.start_time)::date ORDER BY AS1.start_time)  AS  last_login

FROM rs_auto_assign_log AS1

WHERE AS1."action" IN ('autoon','autooff')
) kk 
) mm
WHERE mm.id <> 1

GROUP BY mm.id , mm.previous_login,mm.last_login,mm.duration_sec