/****** Object:  StoredProcedure [dbo].[LayerHouseDaily_InsertUpdate]    Script Date: 6/21/2018 8:03:32 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseDaily_InsertUpdate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LayerHouseDaily_InsertUpdate]
GO
/****** Object:  StoredProcedure [dbo].[LayerHouseDaily_InsertUpdate]    Script Date: 6/21/2018 8:03:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseDaily_InsertUpdate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LayerHouseDaily_InsertUpdate] AS' 
END
GO


--@I_vLayerHouseID is not a parameter for procedure LayerHouseDaily_InsertUpdate.


--SELECT * FROM LayerHouseDaily

ALTER proc [dbo].[LayerHouseDaily_InsertUpdate]
	@I_vLayerHouseWeeklyID int
	,@I_vLayerHouseDailyID int = ''
	,@I_vLayerHouseID int = ''
	,@I_vDateOfRecord varchar(255) = ''
	,@I_vMortality int = ''
	,@I_vFeedDelivery int= ''
	,@I_vDailyEggs int = ''
	,@I_vWater int = ''
	,@I_vMinTemp decimal(16,2) = ''
	,@I_vMaxTemp decimal(16,2) = ''
	,@I_vChlorine decimal(16,2) = ''
	,@I_vRationCode decimal(16,2) = 0.00
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
		,Chlorine = @I_vChlorine
		,RationCode = @I_vRationCode
	where LayerHouseDailyID = @I_vLayerHouseDailyID



	--calculations for the week
	DECLARE @WeekMortality int = (SELECT SUM(Mortality) FROM LayerHouseDaily WHERE LayerHouseWeeklyID = @I_vLayerHouseWeeklyID)
	DECLARE @WeekFeedDel int = (SELECT SUM(FeedDelivery) FROM LayerHouseDaily WHERE LayerHouseWeeklyID = @I_vLayerHouseWeeklyID)
	DECLARE @WeekDailyEggs int = (SELECT SUM(DailyEggs) FROM LayerHouseDaily WHERE LayerHouseWeeklyID = @I_vLayerHouseWeeklyID)
	DECLARE @WeekWater int = (SELECT SUM(Water) FROM LayerHouseDaily WHERE LayerHouseWeeklyID = @I_vLayerHouseWeeklyID)
	DECLARE @WeekHiTemp decimal(16,2) = (SELECT AVG(MaxTemp)FROM LayerHouseDaily WHERE LayerHouseWeeklyID = @I_vLayerHouseWeeklyID)
	DECLARE @WeekLowTemp decimal(16,2) = (SELECT AVG(MinTemp)FROM LayerHouseDaily WHERE LayerHouseWeeklyID = @I_vLayerHouseWeeklyID)

	update LayerHouseWeekly
	SET Mortality = @WeekMortality,TotalFeedDeliveries = @WeekFeedDel,EggsProduced = @WeekDailyEggs,Water=@WeekWater,HiTemp=@WeekHiTemp,LowTemp=@WeekLowTemp
	WHERE LayerHouseWeeklyID = @I_vLayerHouseWeeklyID


 



GO
