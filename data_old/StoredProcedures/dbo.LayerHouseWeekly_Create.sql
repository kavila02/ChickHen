create proc LayerHouseWeekly_Create
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

INSERT INTO LayerHouseWeekly (LayerHouseID, WeekEndingDate,NoOfHens,Mortality,HenWeight,HiTemp,LowTemp,AmmoniaNh3,LightProgram,Rodents,FlyCounts,EggsProduced,CaseWeight,FeedInventory,Water,BeginningInventory,TotalFeedDeliveries,PoundsPerHundred,PercentProduction)
SELECT @LayerHouseID,@WeekEndingDate,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

SET @LayerHouseWeeklyID = SCOPE_IDENTITY()

DECLARE @CompareDate as date = @BeginningDate
WHILE @CompareDate <= @WeekEndingDate
BEGIN
INSERT INTO LayerHouseDaily(LayerHouseWeeklyID,DateOfRecord,Mortality,FeedDelivery,DailyEggs,Water,MinTemp,MaxTemp)
SELECT @LayerHouseWeeklyID,@CompareDate,'','','','','',''
WHERE NOT EXISTS(SELECT 1 FRoM LayerHouseDaily WHERE LayerHouseWeeklyID = @LayerHouseWeeklyID AND DateOfRecord = @CompareDate)


SET @CompareDate = DATEADD(day,1,@CompareDate)
END

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
