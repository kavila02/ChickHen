create proc [dbo].[NewFlockChecklist_Select]
	@FlockID int
	,@UserName nvarchar(255) = ''
AS

Select
	@FlockID as FlockID
	,ChecklistTemplateID
	,convert(varchar,@FlockID) + '&p=' + convert(varchar,ChecklistTemplateID) As linkField
	,TemplateName
from ChecklistTemplate