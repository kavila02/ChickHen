
create proc [dbo].[ChecklistTemplate_DetailAlertSchedule_Recipients_Delete]
	@I_vChecklistTemplate_DetailAlertSchedule_RecipientsID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from ChecklistTemplate_DetailAlertSchedule_Recipients where ChecklistTemplate_DetailAlertSchedule_RecipientsID = @I_vChecklistTemplate_DetailAlertSchedule_RecipientsID