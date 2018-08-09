create proc LayerHouse_Lookup
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select rtrim(l.Location) + ' - ' + rtrim(LayerHouseName) as display
	,LayerHouseID
	,l.Location
	,IsNull(SortOrder,0) as sortOrder
	,l.LocationID
from LayerHouse lh
inner join Location l on lh.LocationID = l.LocationID
--where Active = 1

union all
select '','','',-1,null
where @IncludeBlank = 1

union all
select 'All','','',-1,null
where @IncludeAll = 1

order by 4,3,1
GO
