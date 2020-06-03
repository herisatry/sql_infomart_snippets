-- tickets processing time without tickets with wrong state changes (answer -> in progress)

select ff.tn
       ,ff.my_state_id
       ,ff.my_state_name
       ,sum(ff.dt_next_diff_sec) as s_proc_time_sec
       ,round((sum(ff.dt_next_diff_sec)/60)::numeric,1) as s_proc_time_minut
       ,round((sum(ff.dt_next_diff_sec)/3600)::numeric,1) as s_proc_time_hour
from  (select kk.ticket_id
		      ,kk.tn
		      ,kk.agent
		      ,kk.action_name
		      ,kk.create_time
		      ,kk.next_dt
		      ,kk.dt_next_diff_sec
		      ,kk.state_name
		      ,case 
		             when th3.my_state is null then kk.state_name             
		             else th3.my_state
		       end as my_state_name
		      ,case
		            when th3.my_state = 'answer' then 10
		            when th3.my_state = 'new' then 1
		            else kk.state_id
		       end as my_state_id      
		from (select mm.ticket_id
			       ,mm.tn
			       ,mm.create_time
			       ,lead(mm.create_time,1) over (PARTITION BY mm.ticket_id) as next_dt
			       ,extract(EPOCH from (lead(mm.create_time,1,mm.create_time) over (PARTITION BY mm.ticket_id)) - mm.create_time) as dt_next_diff_sec
			       ,mm.agent
			       ,mm.action_name
			       ,mm.state_id
				   ,mm.state_name
			from  (SELECT th.ticket_id
					       ,t.tn
					       ,th.create_time
					       --,th.create_by
					       ,concat(u.last_name,' ',u.first_name) as agent
					       --,th.id
					       --,th.name as action_name       
					       --,th.queue_id 
					       --,q.name as responsible_tech
					       ,th.state_id
					       ,ts.name as state_name 
					FROM ticket_history th left join ticket t
					                       on th.ticket_id = t.id
					                       left join users u
					                       on th.create_by = u.id
					                       left join queue q
					                       on th.queue_id = q.id
					                       left join ticket_state ts
					                       on th.state_id = ts.id
					                       left join (select distinct the.ticket_id 
					                                  from ticket_history the
					                                  where the.name = '%%answer%%in progress%%'
					                                  ) ee -- tickets with error state					                       
					                       on th.ticket_id = ee.ticket_id
					                       
					where ee.ticket_id is null
					order by th.ticket_id
					         ,th.create_time 
					         ,th.id
			) mm
		) kk left join (select distinct th2.ticket_id
		                             ,th2.create_time
		                             ,case 
		                                   when th2.name = '%%in progress%%answer%%' then 'answer'
		                                   when th2.name = '%%answer%%new%%' then 'new'
		                                   else 'e'
		                              end as my_state
		              from ticket_history th2
		              where (case 
		                           when th2.name = '%%in progress%%answer%%' then 'answer'
		                           when th2.name = '%%answer%%new%%' then 'new'
		                           else 'e'
		                      end) != 'e' 
		              ) th3 -- data for update
		   on kk.ticket_id = th3.ticket_id and kk.create_time = th3.create_time
) ff
where ff.my_state_name in ('new', 'in progress', 'answer')
group by ff.tn
         ,ff.my_state_id
         ,ff.my_state_name

