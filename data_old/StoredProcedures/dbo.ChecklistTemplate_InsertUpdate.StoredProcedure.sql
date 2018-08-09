if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_InsertUpdate' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_InsertUpdate
end
GO

create proc ChecklistTemplate_InsertUpdate
	@I_vChecklistTemplateID int
	,@I_vTemplateName nvarchar(255) = ''
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vChecklistTemplateID = 0
begin
	declare @ChecklistTemplateID table (ChecklistTemplateID int)
	insert into ChecklistTemplate (
		
		TemplateName
	)
	output inserted.ChecklistTemplateID into @ChecklistTemplateID(ChecklistTemplateID)
	select
		
		@I_vTemplateName
	select top 1 @I_vChecklistTemplateID = ChecklistTemplateID, @iRowID = ChecklistTemplateID from @ChecklistTemplateID
end
else
begin
	update ChecklistTemplate
	set
		
		TemplateName = @I_vTemplateName
	where @I_vChecklistTemplateID = ChecklistTemplateID
	select @iRowID = @I_vChecklistTemplateID
end

select @I_vChecklistTemplateID as ID,'forward' As referenceType
