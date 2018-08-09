create proc UserToLocation_InsertUpdate
	@I_vUserToLocationID int
	,@I_vUserTableID int
	,@I_vLocationID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vUserToLocationID = 0
begin
	declare @UserToLocationID table (UserToLocationID int)
	insert into UserToLocation (
		
		UserTableID
		, LocationID
	)
	output inserted.UserToLocationID into @UserToLocationID(UserToLocationID)
	select
		
		@I_vUserTableID
		,@I_vLocationID
	select top 1 @I_vUserToLocationID = UserToLocationID, @iRowID = UserToLocationID from @UserToLocationID
end
else
begin
	update UserToLocation
	set
		
		UserTableID = @I_vUserTableID
		,LocationID = @I_vLocationID
	where @I_vUserToLocationID = UserToLocationID
	select @iRowID = @I_vUserToLocationID
end