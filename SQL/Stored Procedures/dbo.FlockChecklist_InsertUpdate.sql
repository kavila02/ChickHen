
create proc [dbo].[FlockChecklist_InsertUpdate]
	@I_vFlockChecklistID int
	,@I_vFlockChecklistName nvarchar(255) = ''
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vFlockChecklistID = 0
begin
	declare @FlockChecklistID table (FlockChecklistID int)
	insert into FlockChecklist (
		
		FlockChecklistName
	)
	output inserted.FlockChecklistID into @FlockChecklistID(FlockChecklistID)
	select
		
		@I_vFlockChecklistName
	select top 1 @I_vFlockChecklistID = FlockChecklistID, @iRowID = FlockChecklistID from @FlockChecklistID
end
else
begin
	update FlockChecklist
	set
		
		FlockChecklistName = @I_vFlockChecklistName
	where @I_vFlockChecklistID = FlockChecklistID
	select @iRowID = @I_vFlockChecklistID
end

select @I_vFlockChecklistID as ID,'forward' As referenceType