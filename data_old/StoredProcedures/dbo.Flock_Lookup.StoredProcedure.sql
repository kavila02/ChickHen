if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Flock_Lookup' and s.name = 'dbo')
begin
	drop proc Flock_Lookup
end
GO




create proc Flock_Lookup
	@IncludeBlank bit = 1
As

select FlockName,FlockID
from Flock

union all
select '',''
where @IncludeBlank = 1



order by 1
