/****** Object:  StoredProcedure [dbo].[LayerHouseWeekly_Create]    Script Date: 7/31/2018 8:53:36 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseWeekly_Create]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LayerHouseWeekly_Create]
GO
/****** Object:  StoredProcedure [dbo].[LayerHouseWeekly_Create]    Script Date: 7/31/2018 8:53:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseWeekly_Create]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LayerHouseWeekly_Create] AS' 
END
GO


ALTER PROC [dbo].[LayerHouseWeekly_Create]
(
@UserName varchar(100) = '',
@LayerHouseID int,
@WeekEndingDate date
) 
AS



SET @LayerHouseID = nullif(@LayerHouseID,'')
SET @WeekEndingDate = nullif(@WeekEndingDate,'')


if DATEPART(dw,@WeekEndingDate) <> 1
SET @WeekEndingDate = DATEADD([day], ((DATEDIFF([day], '19000107', @WeekEndingDate) / 7) * 7) + 7, '19000107')


DECLARE @BeginningDate AS date
SET @BeginningDate = DATEADD(day,-6,@WeekEndingDate)

DECLARE @LayerHouseWeeklyID int = (SELECT LayerHouseWeeklyID FROM LayerHouseWeekly WHERE @WeekEndingDate = WeekEndingDate AND LayerHouseID = @LayerHouseID)

IF NOT EXISTS(SELECT 1 FROM LayerHouseWeekly WHERE @WeekEndingDate = WeekEndingDate AND LayerHouseID = @LayerHouseID)
BEGIN

INSERT INTO LayerHouseWeekly(LayerHouseID,WeekEndingDate,NoOfHens,BirdAge,Mortality,HenWeight,HiTemp,LowTemp,AmmoniaNh3,LightProgram,Rodents,FlyCounts,EggsProduced,CaseWeight,FeedInventory,Water,BeginningInventory,TotalFeedDeliveries,PoundsPerHundred,PercentProduction,LightIntensity,PercentWeightUniformity,isActive)
SELECT @LayerHouseID,@WeekEndingDate,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

SET @LayerHouseWeeklyID = SCOPE_IDENTITY()

END
ELSE
BEGIN
SET @LayerHouseWeeklyID = (SELECT LayerHouseWeeklyID FROM LayerHouseWeekly WHERE @WeekEndingDate = WeekEndingDate AND LayerHouseID = @LayerHouseID)
END

DECLARE @CompareDate as date = @BeginningDate
WHILE @CompareDate <= @WeekEndingDate
BEGIN
INSERT INTO LayerHouseDaily(LayerHouseID,LayerHouseWeeklyID,DateOfRecord,Mortality,FeedDelivery,DailyEggs,Water,MinTemp,MaxTemp,Chlorine,RationCode)
SELECT @LayerHouseID,@LayerHouseWeeklyID,@CompareDate,0,0,0,0,0,0,0,0
WHERE NOT EXISTS(SELECT 1 FRoM LayerHouseDaily WHERE LayerHouseID = @LayerHouseID AND LayerHouseWeeklyID = @LayerHouseWeeklyID AND DateOfRecord = @CompareDate)


SET @CompareDate = DATEADD(day,1,@CompareDate)
END

--EXEC LayerHouseWeekly_Get @LayerHouseWeeklyID = @LayerHouseWeeklyID
SELECT 
LayerHouseWeeklyID
,WeekEndingDate
,'forward' AS referenceType
FROM LayerHouseWeekly
WHERE LayerHouseID = @LayerHouseID
AND @WeekEndingDate = WeekEndingDate



--EXEC LayerHouseWeekly_Create 'UserName',34,'01/01/2018'

--SELECT * FROM LayerHouseWeekly
GO
