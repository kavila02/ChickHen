if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'PulletGrower_ScheduleReport_Params' and s.name = 'dbo')
begin
	drop proc PulletGrower_ScheduleReport_Params
end
GO
create proc PulletGrower_ScheduleReport_Params
AS

select convert(date,GETDATE()) as reportDate