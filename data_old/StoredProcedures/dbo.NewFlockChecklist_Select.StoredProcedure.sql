if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'NewFlockChecklist_Select' and s.name = 'dbo')
begin
	drop proc NewFlockChecklist_Select
end
GO
create proc NewFlockChecklist_Select
	@FlockID int
	,@UserName nvarchar(255) = ''
AS

Select
	@FlockID as FlockID
	,ChecklistTemplateID
	,convert(varchar,@FlockID) + '&p=' + convert(varchar,ChecklistTemplateID) As linkField
	,TemplateName
from ChecklistTemplate