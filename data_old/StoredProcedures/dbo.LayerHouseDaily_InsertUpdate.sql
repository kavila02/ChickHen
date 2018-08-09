create proc LayerHouseDaily_InsertUpdate
	@I_vLayerHouseWeeklyID int
	,@I_vLayerHouseDailyID int = ''
	,@I_vDateOfRecord varchar(255) = ''
	,@I_vMortality int = ''
	,@I_vFeedDelivery int= ''
	,@I_vDailyEggs int = ''
	,@I_vWater int = ''
	,@I_vMinTemp int = ''
	,@I_vMaxTemp int = ''
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


	update LayerHouseDaily
	set
		LayerHouseWeeklyID = @I_vLayerHouseWeeklyID
		,DateOfRecord = @I_vDateOfRecord
		,Mortality = @I_vMortality
		,FeedDelivery = @I_vFeedDelivery
		,DailyEggs = @I_vDailyEggs
		,Water = @I_vWater
		,MinTemp = @I_vMinTemp
		,MaxTemp = @I_vMaxTemp
	where LayerHouseDailyID = @I_vLayerHouseDailyID



	--calculations for the week
	DECLARE @WeekMortality int = (SELECT SUM(Mortality) FROM LayerHouseDaily WHERE LayerHouseWeeklyID = @I_vLayerHouseWeeklyID)
	DECLARE @WeekFeedDel int = (SELECT SUM(FeedDelivery) FROM LayerHouseDaily WHERE LayerHouseWeeklyID = @I_vLayerHouseWeeklyID)
	DECLARE @WeekDailyEggs int = (SELECT SUM(DailyEggs) FROM LayerHouseDaily WHERE LayerHouseWeeklyID = @I_vLayerHouseWeeklyID)
	DECLARE @WeekWater int = (SELECT SUM(Water) FROM LayerHouseDaily WHERE @I_vLayerHouseWeeklyID = @I_vLayerHouseWeeklyID)
	DECLARE @WeekHiTemp int = (SELECT AVG(MaxTemp)FROM LayerHouseDaily WHERE LayerHouseWeeklyID = @I_vLayerHouseWeeklyID)
	DECLARE @WeekLowTemp int = (SELECT AVG(MinTemp)FROM LayerHouseDaily WHERE LayerHouseWeeklyID = @I_vLayerHouseWeeklyID)

	update LayerHouseWeekly
	SET Mortality = @WeekMortality,TotalFeedDeliveries = @WeekFeedDel,EggsProduced = @WeekDailyEggs,Water=@WeekWater,HiTemp=@WeekHiTemp,LowTemp=@WeekLowTemp
	WHERE LayerHouseWeeklyID = @I_vLayerHouseWeeklyID


GO
