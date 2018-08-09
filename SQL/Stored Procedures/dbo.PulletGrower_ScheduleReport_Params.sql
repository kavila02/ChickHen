create proc PulletGrower_ScheduleReport_Params
AS

select convert(date,GETDATE()) as reportDate