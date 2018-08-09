create proc LayerHouseDaily_Create
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


IF NOT EXISTS(SELECT 1 FROM LayerHouseWeekly WHERE @WeekEndingDate = WeekEndingDate AND LayerHouseID = @LayerHouseID)
BEGIN
	INSERT INTO LayerHouseWeekly (LayerHouseID, WeekEndingDate, NoOfHens, Mortality, HenWeight, HiTemp, LowTemp, AmmoniaNh3, LightProgram, Rodents, FlyCounts, EggsProduced, CaseWeight, FeedInventory, Water, BeginningInventory, TotalFeedDeliveries, PoundsPerHundred, PercentProduction)
	SELECT @LayerHouseID,@WeekEndingDate,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
END

DECLARE @LayerHouseWeeklyID AS int = (SELECT LayerHouseWeeklyID FROM LayerHouseWeekly WHERE LayerHouseID = @LayerHouseID AND @WeekEndingDate = WeekEndingDate)


--create all week if doesn't exist
DECLARE @CompareDate as date = @BeginningDate
WHILE @CompareDate <= @WeekEndingDate
BEGIN
INSERT INTO LayerHouseDaily(LayerHouseWeeklyID,DateOfRecord,Mortality,FeedDelivery,DailyEggs,Water,MinTemp,MaxTemp)
SELECT @LayerHouseWeeklyID,@CompareDate,'','','','','',''
WHERE NOT EXISTS(SELECT 1 FRoM LayerHouseDaily WHERE LayerHouseWeeklyID = @LayerHouseWeeklyID AND DateOfRecord = @CompareDate)


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
