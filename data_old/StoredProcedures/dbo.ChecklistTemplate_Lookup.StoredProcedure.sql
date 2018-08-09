if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_Lookup' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_Lookup
end
GO




create proc ChecklistTemplate_Lookup
	@IncludeBlank bit = 1
As

select TemplateName,ChecklistTemplateID
from ChecklistTemplate

union all
select '',''
where @IncludeBlank = 1



order by 1
