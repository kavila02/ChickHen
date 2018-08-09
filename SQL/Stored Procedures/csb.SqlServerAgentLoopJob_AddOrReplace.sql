
create procedure [csb].[SqlServerAgentLoopJob_AddOrReplace]
	@ServerName sysname,
	@DatabaseName sysname,
	@OwnerLoginName sysname,
	@JobCategoryName sysname,
	@JobName sysname,
	@JobDescription nvarchar(512),
	@Command nvarchar(max)
as

print '
Add job category ' + @JobCategoryName + '...'
if not exists(
		select name 
			from msdb.dbo.syscategories 
			where name = @JobCategoryName 
				and category_class = 1
		) begin
	exec msdb.dbo.sp_add_category  @class='JOB', @type='LOCAL', @name=@JobCategoryName
end

set @JobName = @DatabaseName + ' - ' + @JobName
print '
Delete ' + @JobName + '...'
if exists (
		select 1
			from msdb.dbo.sysjobs j
			where j.name = @JobName
		) begin
	exec msdb.dbo.sp_delete_job @job_name=@JobName
end

print '
Add ' + @JobName + '...'
declare @JobId binary(16)
exec msdb.dbo.sp_add_job  @job_name=@JobName, @enabled=1, @notify_level_eventlog=0, 
		@notify_level_email=0, @notify_level_netsend=0, @notify_level_page=0, 
		@delete_level=0, @description=@JobDescription, 
		@category_name=@JobCategoryName, @owner_login_name=@OwnerLoginName, 
		@job_id=@JobId output

print '
Add job step to ' + @JobName + '...'
set @Command = 'while 1 = 1 begin
	' + @Command + '
	waitfor delay ''00:00:00.100''
end'
exec msdb.dbo.sp_add_jobstep  @job_id=@JobId, @step_name='Loop', @step_id=1, 
		@cmdexec_success_code=0, @on_success_action=1, @on_success_step_id=0, 
		@on_fail_action=2, @on_fail_step_id=0, @retry_attempts=0, 
		@retry_interval=0, @os_run_priority=0, @subsystem='TSQL', 
		@database_name=@DatabaseName, @flags=0, @command=@Command

print '
Update ' + @JobName + ' to start at step one...'
exec msdb.dbo.sp_update_job @job_id=@JobId, @start_step_id=1

print '
Add job server for ' + @JobName + '...'
exec msdb.dbo.sp_add_jobserver @job_id=@JobId, @server_name=@ServerName