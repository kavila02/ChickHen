create proc LayerHouseDaily_Get
(
@LayerHouseWeeklyID int
) 
AS


SELECT 
lhd.LayerHouseDailyID
,LayerHouseWeeklyID
,CONVERT(varchar(255),DateOfRecord,1) AS DateOfRecord
,Mortality
,FeedDelivery
,DailyEggs
,Water
,MinTemp
,MaxTemp
FROM LayerHouseDaily lhd
WHERE LayerHouseWeeklyID = @LayerHouseWeeklyID



GO
