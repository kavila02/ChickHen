if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockChecklist_Update' and s.name = 'dbo')
begin
	drop proc FlockChecklist_Update
end
GO

create proc FlockChecklist_Update
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


