
create proc [dbo].[FlockChecklist_Detail_Lookup]
	@FlockChecklistID int
	,@IncludeBlank bit = 1
As

select StepName,FlockChecklist_DetailID,StepOrder
from FlockChecklist_Detail
where FlockChecklistID = @FlockChecklistID

union all
select '','',0
where @IncludeBlank = 1

Order by StepOrder