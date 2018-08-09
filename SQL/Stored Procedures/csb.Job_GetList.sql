
create procedure [csb].[Job_GetList]
as

declare @tmp_xp_sqlagent_enum_jobs table (
	job_id uniqueidentifier not null,
	last_run_date int not null,
	last_run_time int not null,
	next_run_date int not null,
	next_run_time int not null,
	next_run_schedule_id int not null,
	requested_to_run int not null, -- bool
	request_source int not null,
	request_source_id sysname collate database_default null,
	running int not null, -- bool
	current_step int not null,
	current_retry_attempt int not null,
	job_state int not null
	)
insert @tmp_xp_sqlagent_enum_jobs 
	exec master.dbo.xp_sqlagent_enum_jobs @is_sysadmin = 1, @job_owner = ''


declare @tmp_sp_help_jobhistory table
(
    instance_id int null, 
    job_id uniqueidentifier null, 
    job_name sysname null, 
    step_id int null, 
    step_name sysname null, 
    sql_message_id int null, 
    sql_severity int null, 
    message nvarchar(4000) null, 
    run_status int null, 
    run_date int null, 
    run_time int null, 
    run_duration int null, 
    operator_emailed sysname null, 
    operator_netsent sysname null, 
    operator_paged sysname null, 
    retries_attempted int null, 
    server sysname null  
)
insert into @tmp_sp_help_jobhistory 
exec msdb.dbo.sp_help_jobhistory 
    @mode='FULL' 

;with FilteredJobIDs as (
	select distinct j.job_id
		from msdb.dbo.sysjobs j
		join csb.JobFilter jf on j.name like jf.NameFilter
)
select j.job_id as JobID, j.name as Name,
		case when j.description <> 'No description available.' 
			then j.description end as Description,
		case s.running when 0 then 'No' when 1 then 'Yes' 
			else 'Unknown (' + CAST(s.running as varchar) + ')' end 
			as IsRunning,
		case when next_run_date <> 0 
			then CAST(CAST(s.next_run_date / 10000 as varchar) + '-' 
				+ CAST((s.next_run_date % 10000) / 100 as varchar) + '-'
				+ CAST(s.next_run_date % 100 as varchar) + ' '
				+ CAST(s.next_run_time / 10000 as varchar) + ':'
				+ CAST((s.next_run_time % 10000) / 100 as varchar) + ':'
				+ CAST(s.next_run_time % 100 as varchar) as datetime2)
				end as NextRunDateTime, 
		case when last_run_date <> 0 
			then CAST(CAST(s.last_run_date / 10000 as varchar) + '-' 
				+ CAST((s.last_run_date % 10000) / 100 as varchar) + '-'
				+ CAST(s.last_run_date % 100 as varchar) + ' '
				+ CAST(s.last_run_time / 10000 as varchar) + ':'
				+ CAST((s.last_run_time % 10000) / 100 as varchar) + ':'
				+ CAST(s.last_run_time % 100 as varchar) as datetime2)
				end as LastRunDateTime, 
			j.date_modified as ModifyDateTime, j.date_created as CreateDateTime, 
			suser_sname(j.owner_sid) as Owner, LastRunErrorMessage
	from msdb.dbo.sysjobs j
	join FilteredJobIDs jf on j.job_id = jf.job_id
	left join @tmp_xp_sqlagent_enum_jobs s on j.job_id = s.job_id
	left join (
		select job_id, run_date, run_time,
				case COUNT(*)
					when 0
						then null
					when 1
						then MAX(message)
					when 2 then MIN(message) + ' | ' + MAX(message)
					else MIN(message) + ' | ' + MAX(message) + ' | ' 
							+ CAST(COUNT(*) - 2 as varchar) + ' more...'
					end as LastRunErrorMessage
			from @tmp_sp_help_jobhistory
			where sql_severity <> 0
			group by job_id, run_date, run_time
		) jh on j.job_id = jh.job_id
			and s.last_run_date = jh.run_date
			and s.last_run_time = jh.run_time
	order by j.name