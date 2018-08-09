if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'DeleteMajorObject' and s.name = 'dbo')
begin
	drop proc DeleteMajorObject
end
GO
create proc DeleteMajorObject
	@I_vEntityID varchar(20)
	,@I_vFlockID int = 0
	,@I_vFlockChecklistID int = 0
	,@I_vChecklistTemplateID int = 0
	, @O_iErrorState int=0 output 
	, @oErrString varchar(255)='' output
	, @iRowID int=0 output
AS

If @I_vEntityID = 'Flock'
Begin
	exec Flock_Delete @FlockID = @I_vFlockID
End

If @I_vEntityID = 'FlockChecklist'
Begin
	exec FlockChecklist_Delete @FlockChecklistID = @I_vFlockChecklistID
End

If @I_vEntityID = 'ChecklistTemplate'
Begin
	exec ChecklistTemplate_Delete @ChecklistTemplateID = @I_vChecklistTemplateID
End