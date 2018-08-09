if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockChecklist_Detail_Lookup' and s.name = 'dbo')
begin
	drop proc FlockChecklist_Detail_Lookup
end
GO

create proc FlockChecklist_Detail_Lookup
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