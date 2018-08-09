if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_DetailAlertSchedule_Delete' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_DetailAlertSchedule_Delete
end
GO
create proc ChecklistTemplate_DetailAlertSchedule_Delete
	@I_vChecklistTemplate_DetailAlertScheduleID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

--foreign keys exist for this table. These should 
update FlockChecklist_DetailAlertSchedule set ChecklistTemplate_DetailAlertScheduleID = null where ChecklistTemplate_DetailAlertScheduleID = @I_vChecklistTemplate_DetailAlertScheduleID

delete from ChecklistTemplate_DetailAlertSchedule_Recipients where ChecklistTemplate_DetailAlertScheduleID = @I_vChecklistTemplate_DetailAlertScheduleID
delete from ChecklistTemplate_DetailAlertSchedule where ChecklistTemplate_DetailAlertScheduleID = @I_vChecklistTemplate_DetailAlertScheduleID