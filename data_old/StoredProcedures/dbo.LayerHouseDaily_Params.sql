create proc LayerHouseDaily_Params
@rowID AS int
AS

select convert(date,WeekEndingDate) as weekEndDate
, convert(int,LayerHouseID) as LayerHouseID
FROM LayerHouseWeekly
WHERE LayerHouseWeeklyID = @rowID

GO
