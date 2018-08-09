create proc HousingDates_Get
AS

select
LayerHouseID
,HatchDate_First
,HousingDate_Average
,HousingOutDate
from Flock
where LayerHouseID is not null
	and HousingDate_Average is not null
order by LayerHouseID,HousingDate_Average