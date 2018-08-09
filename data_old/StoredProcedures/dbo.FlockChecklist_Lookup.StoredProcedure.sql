if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockChecklist_Lookup' and s.name = 'dbo')
begin
	drop proc FlockChecklist_Lookup
end
GO




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
