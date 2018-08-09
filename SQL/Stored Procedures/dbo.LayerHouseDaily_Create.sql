/****** Object:  StoredProcedure [dbo].[LayerHouseDaily_Create]    Script Date: 7/31/2018 8:53:36 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseDaily_Create]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LayerHouseDaily_Create]
GO
/****** Object:  StoredProcedure [dbo].[LayerHouseDaily_Create]    Script Date: 7/31/2018 8:53:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseDaily_Create]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LayerHouseDaily_Create] AS' 
END
GO


ALTER PROC [dbo].[LayerHouseDaily_Create]
(
@UserName varchar(100),
@LayerHouseID int,
@DateOfRecord varchar(255)
) 
AS


DECLARE @WeekEndingDate as date
select @WeekEndingDate = DATEADD([day], ((DATEDIFF([day], '19000107', @DateOfRecord) / 7) * 7) + 7, '19000107')

DECLARE @BeginningDate AS date
SET @BeginningDate = DATEADD(day,-6,@WeekEndingDate)

DECLARE @LayerHouseDailyID int = (SELECT LayerHouseDailyID FROM LayerHouseDaily WHERE @DateOfRecord = DateOfRecord AND LayerHouseID = @LayerHouseID)

IF NOT EXISTS(SELECT 1 FROM LayerHouseWeekly WHERE @WeekEndingDate = WeekEndingDate AND LayerHouseID = @LayerHouseID)
BEGIN
	INSERT INTO LayerHouseWeekly(LayerHouseID,WeekEndingDate,NoOfHens,BirdAge,Mortality,HenWeight,HiTemp,LowTemp,AmmoniaNh3,LightProgram,Rodents,FlyCounts,EggsProduced,CaseWeight,FeedInventory,Water,BeginningInventory,TotalFeedDeliveries,PoundsPerHundred,PercentProduction,Consumption,isActive)
	SELECT @LayerHouseID,@WeekEndingDate,0[NoOfHens],0[BirdAge],0[Mortality],0[HenWeight],0[HiTemp],0[LowTemp],0[AmmoniaNh3],0[LightProgram],0[Rodents],0[FlyCounts],0[EggsProduced],0[CaseWeight],0[FeedInventory],0[Water],0[BeginningInventory],0[TotalFeedDeliveries],0[PoundsPerHundred],0[PercentProduction],0[Consumption],0[isActive]
END

DECLARE @LayerHouseWeeklyID AS int = (SELECT LayerHouseWeeklyID FROM LayerHouseWeekly WHERE LayerHouseID = @LayerHouseID AND @WeekEndingDate = WeekEndingDate)

IF NOT EXISTS(SELECT 1 FROM LayerHouseDaily WHERE @DateOfRecord = DateOfRecord AND LayerHouseID = @LayerHouseID)
BEGIN
	INSERT INTO LayerHouseDaily(LayerHouseID,LayerHouseWeeklyID,DateOfRecord,Mortality,FeedDelivery,DailyEggs,Water,MinTemp,MaxTemp,Chlorine,RationCode)
	SELECT @LayerHouseID,@LayerHouseWeeklyID,@DateOfRecord,0,0,0,0,0,0,0,0

	SET @LayerHouseDailyID = SCOPE_IDENTITY()
END

--create all week if doesn't exist
DECLARE @CompareDate as date = @BeginningDate
WHILE @CompareDate <= @WeekEndingDate
BEGIN
INSERT INTO LayerHouseDaily(LayerHouseID,LayerHouseWeeklyID,DateOfRecord,Mortality,FeedDelivery,DailyEggs,Water,MinTemp,MaxTemp,Chlorine,RationCode)
SELECT @LayerHouseID,@LayerHouseWeeklyID,@CompareDate,0,0,0,0,0,0,0,0
WHERE NOT EXISTS(SELECT 1 FRoM LayerHouseDaily WHERE LayerHouseID = @LayerHouseID AND LayerHouseWeeklyID = @LayerHouseWeeklyID AND DateOfRecord = @CompareDate)


SET @CompareDate = DATEADD(day,1,@CompareDate)
END

EXEC LayerHouseDaily_Get @LayerHouseWeeklyID = @LayerHouseWeeklyID

--SELECT 
--LayerHouseDailyID
--,'forward' AS referenceType
--FROM LayerHouseDaily
--WHERE LayerHouseID = @LayerHouseID
--AND @DateOfRecord = DateOfRecord





GO
