



create proc ProductBreed_Lookup
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select ProductBreed,ProductBreedID,SortOrder,NumberOfWeeks,WeeksHatchToHouse
from ProductBreed
where IsActive = 1

union all
select '','',0,null,null
where @IncludeBlank = 1

union all
select 'All','',0,null,null
where @IncludeAll = 1



order by 3