if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'HousingDates_Get' and s.name = 'dbo')
begin
	drop proc HousingDates_Get
end
GO
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