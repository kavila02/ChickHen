if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_DetailAlertSchedule_Recipients_InsertUpdate' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_DetailAlertSchedule_Recipients_InsertUpdate
end
GO
create proc ChecklistTemplate_DetailAlertSchedule_Recipients_InsertUpdate
	@I_vChecklistTemplate_DetailAlertSchedule_RecipientsID int
	,@I_vChecklistTemplate_DetailAlertScheduleID int
	,@I_vRecipientType smallint = null
	,@I_vContactRoleID int = null
	,@I_vContactID int = null
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

if @I_vChecklistTemplate_DetailAlertSchedule_RecipientsID = 0
begin
	declare @ChecklistTemplate_DetailAlertSchedule_RecipientsID table (ChecklistTemplate_DetailAlertSchedule_RecipientsID int)
	insert into ChecklistTemplate_DetailAlertSchedule_Recipients (
		
		ChecklistTemplate_DetailAlertScheduleID
		, RecipientType
		, ContactRoleID
		, ContactID
	)
	output inserted.ChecklistTemplate_DetailAlertSchedule_RecipientsID into @ChecklistTemplate_DetailAlertSchedule_RecipientsID(ChecklistTemplate_DetailAlertSchedule_RecipientsID)
	select
		
		@I_vChecklistTemplate_DetailAlertScheduleID
		,@I_vRecipientType
		,@I_vContactRoleID
		,@I_vContactID
	select top 1 @I_vChecklistTemplate_DetailAlertSchedule_RecipientsID = ChecklistTemplate_DetailAlertSchedule_RecipientsID, @iRowID = ChecklistTemplate_DetailAlertSchedule_RecipientsID from @ChecklistTemplate_DetailAlertSchedule_RecipientsID
end
else
begin
	update ChecklistTemplate_DetailAlertSchedule_Recipients
	set
		
		ChecklistTemplate_DetailAlertScheduleID = @I_vChecklistTemplate_DetailAlertScheduleID
		,RecipientType = @I_vRecipientType
		,ContactRoleID = @I_vContactRoleID
		,ContactID = @I_vContactID
	where @I_vChecklistTemplate_DetailAlertSchedule_RecipientsID = ChecklistTemplate_DetailAlertSchedule_RecipientsID
	select @iRowID = @I_vChecklistTemplate_DetailAlertSchedule_RecipientsID
end