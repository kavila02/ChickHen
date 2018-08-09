if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_Get' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_Get
end
GO
create proc ChecklistTemplate_Get
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