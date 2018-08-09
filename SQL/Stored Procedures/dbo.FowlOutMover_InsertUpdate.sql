create proc [dbo].[FowlOutMover_InsertUpdate]
	@I_vFowlOutMoverID int
	,@I_vFowlOutMover nvarchar(255)
	,@I_vSortOrder int
	,@I_vIsActive bit
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vFowlOutMoverID = 0
begin
	declare @FowlOutMoverID table (FowlOutMoverID int)
	insert into FowlOutMover (
		
		FowlOutMover
		, SortOrder
		, IsActive
	)
	output inserted.FowlOutMoverID into @FowlOutMoverID(FowlOutMoverID)
	select
		
		@I_vFowlOutMover
		,@I_vSortOrder
		,@I_vIsActive
	select top 1 @I_vFowlOutMoverID = FowlOutMoverID, @iRowID = FowlOutMoverID from @FowlOutMoverID
end
else
begin
	update FowlOutMover
	set
		
		FowlOutMover = @I_vFowlOutMover
		,SortOrder = @I_vSortOrder
		,IsActive = @I_vIsActive
	where @I_vFowlOutMoverID = FowlOutMoverID
	select @iRowID = @I_vFowlOutMoverID
end