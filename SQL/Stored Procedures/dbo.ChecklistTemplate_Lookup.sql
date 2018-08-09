



create proc ChecklistTemplate_Lookup
	@IncludeBlank bit = 1
As

select TemplateName,ChecklistTemplateID
from ChecklistTemplate

union all
select '',''
where @IncludeBlank = 1



order by 1