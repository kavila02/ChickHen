if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Hatchery_Lookup' and s.name = 'dbo')
begin
	drop proc Hatchery_Lookup
end
GO
create proc Hatchery_Lookup
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select Hatchery,HatcheryID,SortOrder
from Hatchery
where IsActive = 1

union all
select '','',0
where @IncludeBlank = 1

union all
select 'All','',0
where @IncludeAll = 1

Order by SortOrder