if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_DetailAlertSchedule_Recipients_Delete' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_DetailAlertSchedule_Recipients_Delete
end
GO
create proc ChecklistTemplate_DetailAlertSchedule_Recipients_Delete
	@I_vChecklistTemplate_DetailAlertSchedule_RecipientsID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from ChecklistTemplate_DetailAlertSchedule_Recipients where ChecklistTemplate_DetailAlertSchedule_RecipientsID = @I_vChecklistTemplate_DetailAlertSchedule_RecipientsID