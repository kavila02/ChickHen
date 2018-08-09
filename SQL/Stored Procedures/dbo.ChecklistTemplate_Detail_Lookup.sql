
create proc [dbo].[ChecklistTemplate_Detail_Lookup]
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