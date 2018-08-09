create proc LayerHouseWeekly_Get
(
@LayerHouseWeeklyID int
) 
AS

declare @currentDate date, @LayerHouseID int, @FlockID int, @HatchDate date
select @currentDate = w.WeekEndingDate
	,@LayerHouseID = w.LayerHouseID
	,@FlockID = f.FlockID
	,@HatchDate = f.HatchDate_First
from LayerHouseWeekly w
	left outer join Flock f on w.LayerHouseID = f.LayerHouseID and w.WeekEndingDate between f.HousingDate_First and f.HousingOutDate
where LayerHouseWeeklyID = @LayerHouseWeeklyID



SELECT 
LayerHouseWeeklyID
,lhw.LayerHouseID
,lh.LayerHouseName
,WeekEndingDate
,Mortality
,HenWeight
,HiTemp
,LowTemp
,AmmoniaNh3
,LightProgram
,Rodents
,FlyCounts
,EggsProduced
,CaseWeight
,FeedInventory
,Water
,BeginningInventory
,TotalFeedDeliveries
,NoOfHens
,--BirdAge
	DATEDIFF(wk,@HatchDate,@currentDate) as BirdAge
,PoundsPerHundred
,PercentProduction
,RTRIM(l.Location) + ' - ' + RTRIM(lh.LayerHouseName) AS display
FROM LayerHouseWeekly lhw
LEFT JOIN LayerHouse lh ON lh.LayerHouseID = lhw.LayerHouseID
LEFT JOIN Location l ON l.LocationID = lh.LocationID
WHERE LayerHouseWeeklyID = @LayerHouseWeeklyID


GO
