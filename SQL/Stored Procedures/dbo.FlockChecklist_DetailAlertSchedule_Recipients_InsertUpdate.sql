create proc [dbo].[FlockChecklist_DetailAlertSchedule_Recipients_InsertUpdate]
	@I_vFlockChecklist_DetailAlertSchedule_RecipientsID int
	,@I_vFlockChecklist_DetailAlertScheduleID int
	,@I_vRecipientType smallint = null
	,@I_vContactRoleID int = null
	,@I_vContactID int = null
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

if @I_vFlockChecklist_DetailAlertSchedule_RecipientsID = 0
begin
	declare @FlockChecklist_DetailAlertSchedule_RecipientsID table (FlockChecklist_DetailAlertSchedule_RecipientsID int)
	insert into FlockChecklist_DetailAlertSchedule_Recipients (
		
		FlockChecklist_DetailAlertScheduleID
		, RecipientType
		, ContactRoleID
		, ContactID
	)
	output inserted.FlockChecklist_DetailAlertSchedule_RecipientsID into @FlockChecklist_DetailAlertSchedule_RecipientsID(FlockChecklist_DetailAlertSchedule_RecipientsID)
	select
		
		@I_vFlockChecklist_DetailAlertScheduleID
		,@I_vRecipientType
		,@I_vContactRoleID
		,@I_vContactID
	select top 1 @I_vFlockChecklist_DetailAlertSchedule_RecipientsID = FlockChecklist_DetailAlertSchedule_RecipientsID, @iRowID = FlockChecklist_DetailAlertSchedule_RecipientsID from @FlockChecklist_DetailAlertSchedule_RecipientsID
end
else
begin
	update FlockChecklist_DetailAlertSchedule_Recipients
	set
		
		FlockChecklist_DetailAlertScheduleID = @I_vFlockChecklist_DetailAlertScheduleID
		,RecipientType = @I_vRecipientType
		,ContactRoleID = @I_vContactRoleID
		,ContactID = @I_vContactID
	where @I_vFlockChecklist_DetailAlertSchedule_RecipientsID = FlockChecklist_DetailAlertSchedule_RecipientsID
	select @iRowID = @I_vFlockChecklist_DetailAlertSchedule_RecipientsID
end