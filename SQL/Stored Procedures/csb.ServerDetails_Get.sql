
create procedure [csb].[ServerDetails_Get]
as

declare @installFolder nvarchar(4000)  
 
exec master.dbo.xp_instance_regread 'HKEY_LOCAL_MACHINE', 'Software\Microsoft\MSSQLServer\Setup', 
      'SQLPath', @installFolder output, 'no_output' 

select 
--WebServerName, WebServerIpAddress, WebServerVersion,
--		WebSiteRootFolder,
		@@SERVERNAME as DatabaseServerName, @@VERSION as DatabaseServerVersion, 
		@installFolder as DatabaseServerInstallFolder,
		CONVERT(varchar(25), DB.name) as DatabaseName,
		case compatibility_level
			when 60 then '60 (SQL Server 6.0)'
			when 65 then '65 (SQL Server 6.5)'
			when 70 then '70 (SQL Server 7.0)'
			when 80 then '80 (SQL Server 2000)'
			when 90 then '90 (SQL Server 2005)'
			when 100 then '100 (SQL Server 2008)'
			else convert(varchar, compatibility_level)
			end as CompatibilityLevel,
		create_date as CreateDateTime,
		ISNULL((
			select top 1
					case bk.type 
							when 'D' then 'Full' 
							when 'I' then 'Differential' 
							when 'L' then 'Transaction log' end + ' � '
						+ LTRIM(ISNULL(STR(ABS(DATEDIFF(DAY, GETDATE(),Backup_finish_date))) + ' days ago', 'NEVER')) + ' � '
						+ CAST(DATEDIFF(second, BK.backup_start_date, BK.backup_finish_date) as varchar) 
						+ ' seconds ('
						+ CONVERT(varchar(20), backup_start_date, 120) + ' - ' 
						+ RIGHT(CONVERT(varchar(20), backup_finish_date, 120), 8) + ')' 
				from msdb..backupset BK 
				where BK.database_name = DB.name 
				order by backup_set_id desc),'-') as LastBackup,
		(select SUM((size*8)/1024) 
			from sys.database_files 
			where type_desc = 'rows') as DataMB,
		(select SUM((size*8)/1024) 
			from sys.database_files 
			where type_desc = 'log') as LogMB,
		recovery_model_desc as RecoveryModel,
		page_verify_option_desc as PageVerifyOption,
		case when is_auto_create_stats_on = 1 then 'On' else 'Off' end as AutoCreateStats,
		case when is_auto_update_stats_on = 1 then 'On' else 'Off' end as AutoUpdateStats
	from sys.databases DB
	where db.name = DB_NAME()