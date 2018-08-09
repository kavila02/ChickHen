CREATE proc [dbo].[Hatchery_Lookup]
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