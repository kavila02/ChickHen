create proc LayerHouseWeekly_Params
AS


select convert(date,convert(date,GETDATE())) as weekEndDate
, convert(int,'') as LayerHouseID

GO
