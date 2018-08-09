create proc Additive_Lookup
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select Additive,AdditiveID,SortOrder
from Additive
where IsActive = 1

union all
select '','',0
where @IncludeBlank = 1

union all
select 'All','',0
where @IncludeAll = 1
order by 3