create proc [dbo].[ChecklistTemplate_Get]
@ChecklistTemplateID int = 0
,@includeNew bit = 1
,@UserName nvarchar(255) = ''
As

Select
	ChecklistTemplateID
	,TemplateName
from ChecklistTemplate
where @ChecklistTemplateID = ChecklistTemplateID
union all
select
	convert(int,0) As ChecklistTEmplateID
	,convert(nvarchar(255),'') As TemplateName
where @includeNew = 1