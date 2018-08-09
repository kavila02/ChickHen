if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockChecklist_DetailAlertSchedule_Delete' and s.name = 'dbo')
begin
	drop proc FlockChecklist_DetailAlertSchedule_Delete
end
GO
create proc FlockChecklist_DetailAlertSchedule_Delete
	@I_vFlockChecklist_DetailAlertScheduleID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

delete from FlockChecklist_DetailAlertSchedule_Recipients where FlockChecklist_DetailAlertScheduleID = @I_vFlockChecklist_DetailAlertScheduleID
delete from FlockChecklist_DetailAlertSchedule where FlockChecklist_DetailAlertScheduleID = @I_vFlockChecklist_DetailAlertScheduleID