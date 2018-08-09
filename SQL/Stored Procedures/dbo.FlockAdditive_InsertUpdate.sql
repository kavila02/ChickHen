create proc FlockAdditive_InsertUpdate
	@I_vFlockAdditiveID int
	,@I_vFlockID int
	,@I_vAdditiveID int = null
	,@I_vAdditiveStatusID int = null
	,@I_vFlockAdditiveNotes nvarchar(255) = ''
	,@I_vStartDate date = null
	,@I_vEndDate date = null
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vFlockAdditiveID = 0
begin
	declare @FlockAdditiveID table (FlockAdditiveID int)
	insert into FlockAdditive (
		
		FlockID
		, AdditiveID
		, AdditiveStatusID
		, FlockAdditiveNotes
		, StartDate
		, EndDate
	)
	output inserted.FlockAdditiveID into @FlockAdditiveID(FlockAdditiveID)
	select
		
		@I_vFlockID
		,@I_vAdditiveID
		,@I_vAdditiveStatusID
		,@I_vFlockAdditiveNotes
		,@I_vStartDate
		,@I_vEndDate
	select top 1 @I_vFlockAdditiveID = FlockAdditiveID, @iRowID = FlockAdditiveID from @FlockAdditiveID
end
else
begin
	update FlockAdditive
	set
		
		FlockID = @I_vFlockID
		,AdditiveID = @I_vAdditiveID
		,AdditiveStatusID = @I_vAdditiveStatusID
		,FlockAdditiveNotes = @I_vFlockAdditiveNotes
		,StartDate = @I_vStartDate
		,EndDate = @I_vEndDate
	where @I_vFlockAdditiveID = FlockAdditiveID
	select @iRowID = @I_vFlockAdditiveID
end