if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_Detail_Lookup' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_Detail_Lookup
end
GO

create proc ChecklistTemplate_Detail_Lookup
	@ChecklistTemplateID int
	,@IncludeBlank bit = 1
As

select StepName,ChecklistTemplate_DetailID,StepOrder
from ChecklistTemplate_Detail
where ChecklistTemplateID = @ChecklistTemplateID

union all
select '','',0
where @IncludeBlank = 1

Order by StepOrder