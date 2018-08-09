CREATE proc [dbo].[PulletGrower_Lookup]
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select PulletGrower,PulletGrowerID,SortOrder,dbo.FormatIntComma(Capacity) as Capacity
from PulletGrower
where IsActive = 1

union all
select '','',0,''
where @IncludeBlank = 1

union all
select 'All','',0,''
where @IncludeAll = 1

order by 3