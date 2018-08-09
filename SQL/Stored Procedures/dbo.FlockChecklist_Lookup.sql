



create proc FlockChecklist_Lookup
	@IncludeBlank bit = 1
As

select f.FlockName + '- ' + FlockChecklistName,FlockChecklistID
from FlockChecklist fc
inner join Flock f on fc.FlockID = f.FlockID

union all
select '',''
where @IncludeBlank = 1



order by 1