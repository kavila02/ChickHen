
create proc [dbo].[FlockChecklist_Update]
	@I_vFlockChecklistID int
	,@I_vFlockChecklistName nvarchar(255) = ''
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

	update FlockChecklist
	set
		
		FlockChecklistName = @I_vFlockChecklistName
	where @I_vFlockChecklistID = FlockChecklistID
	select @iRowID = @I_vFlockChecklistID