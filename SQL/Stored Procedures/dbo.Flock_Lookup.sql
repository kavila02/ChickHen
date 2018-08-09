



create proc Flock_Lookup
	@IncludeBlank bit = 1
As

select FlockName,FlockID
from Flock

union all
select '',''
where @IncludeBlank = 1



order by 1