if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_GetList' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_GetList
end
GO
create proc ChecklistTemplate_GetList
@UserName nvarchar(255) = ''
As

Select
	ChecklistTemplateID
	,TemplateName
from ChecklistTemplate