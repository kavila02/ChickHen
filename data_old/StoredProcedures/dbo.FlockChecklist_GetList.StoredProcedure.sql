if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockChecklist_GetList' and s.name = 'dbo')
begin
	drop proc FlockChecklist_GetList
end
GO
create proc FlockChecklist_GetList
@FlockID int = 0
,@UserName nvarchar(255) = ''
As

Select
	FlockChecklistID
	,rtrim(FlockChecklistName) as FlockChecklistName
	,(Select top 1 rtrim(StepName) + ' - ' + convert(nvarchar,DateOfAction,101) from FlockChecklist_Detail d where fc.FlockChecklistID = d.FlockChecklistID and CompletedDate is null order by DateOfAction)
		As NextStep
	,f.FlockName
	,f.FlockID
from FlockChecklist fc
inner join Flock f on fc.FlockID = f.FlockID
Where @FlockID in (fc.FlockID, 0)