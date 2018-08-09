create proc [dbo].[ChecklistTemplate_GetList]
@UserName nvarchar(255) = ''
As

Select
	ChecklistTemplateID
	,TemplateName
from ChecklistTemplate