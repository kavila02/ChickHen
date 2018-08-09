create proc FlockEvent_InsertUpdate
	@I_vFlockEventID int
	,@I_vFlockID int
	,@I_vEventDescription varchar(255) = ''
	,@I_vFollowUpDescription varchar(255) = ''
	,@I_vCreatedBy_UserTableID int = null
	,@I_vFollowUpCreatedBy_UserTableID int = null
	,@I_vFollowUpContact int = null
	,@I_vUserName nvarchar(255) =''
	,@I_vEventDate date = null
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

declare @UserTableID int, @currentFollowUp varchar(255)
select @UserTableID = UserTableID from csb.UserTable where UserID = @I_vUserName

select @currentFollowUp = FollowUpDescription from FlockEvent where FlockEventID = @I_vFlockEventID
if IsNull(@currentFollowUp,'') <> IsNull(@I_vFollowUpDescription,'') and IsNull(@I_vFollowUpDescription,'') > ''
	select @I_vFollowUpCreatedBy_UserTableID = @UserTableID

if @I_vFlockEventID = 0
begin
	declare @FlockEventID table (FlockEventID int)
	insert into FlockEvent (
		
		FlockID
		, EventDescription
		, FollowUpDescription
		, CreatedBy_UserTableID
		, FollowUpCreatedBy_UserTableID
		, FollowUpContact
		, EventDate
	)
	output inserted.FlockEventID into @FlockEventID(FlockEventID)
	select
		
		@I_vFlockID
		,@I_vEventDescription
		,@I_vFollowUpDescription
		,@UserTableID
		,@I_vFollowUpCreatedBy_UserTableID
		,@I_vFollowUpContact
		,GETDATE()
	select top 1 @I_vFlockEventID = FlockEventID, @iRowID = FlockEventID from @FlockEventID
end
else
begin
	update FlockEvent
	set
		
		EventDescription = @I_vEventDescription
		,FollowUpDescription = @I_vFollowUpDescription
		,CreatedBy_UserTableID = @I_vCreatedBy_UserTableID
		,FollowUpCreatedBy_UserTableID = @I_vFollowUpCreatedBy_UserTableID
		,FollowUpContact = @I_vFollowUpContact
		,EventDate = @I_vEventDate
	where @I_vFlockEventID = FlockEventID
	select @iRowID = @I_vFlockEventID
end
select @I_vFlockEventID as ID,'forward' As referenceType