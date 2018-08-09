/****** Object:  StoredProcedure [dbo].[LayerHouseWeekly_Get]    Script Date: 6/21/2018 8:03:32 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseWeekly_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LayerHouseWeekly_Get]
GO
/****** Object:  StoredProcedure [dbo].[LayerHouseWeekly_Get]    Script Date: 6/21/2018 8:03:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseWeekly_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LayerHouseWeekly_Get] AS' 
END
GO

ALTER PROC [dbo].[LayerHouseWeekly_Get]
(
@LayerHouseWeeklyID int
) 
AS

DECLARE @WeekDate as date = (SELECT WeekEndingDate FROM LayerHouseWeekly WHERE LayerHouseWeeklyID = @LayerHouseWeeklyID)

DECLARE @BirdAge AS int = (SELECT TOP 1
DATEDIFF(wk,HatchDate_First,@WeekDate) As FowlAge
FROM LayerHouseWeekly lhw
JOIN LayerHouse lh ON lh.LayerHouseID = lhw.LayerHouseID
JOIN Flock f ON f.LayerHouseID = lh.LayerHouseID  AND GETDATE() between f.HousingDate_First and f.HousingOutDate
WHERE lhw.LayerHouseWeeklyID = @LayerHouseWeeklyID)

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
,ISNULL(@BirdAge,0) AS BirdAge
,IIF(NoOfHens=0,0,CONVERT(decimal(16,2),(CONVERT(decimal(16,2),BeginningInventory + TotalFeedDeliveries - FeedInventory) / (CONVERT(decimal(16,2),NoOfHens) / 100)) / 7)) AS  PoundsPerHundred
--,CAST((((CAST((BeginningInventory + TotalFeedDeliveries - FeedInventory)/IIF(NoOfHens = 0,1,NoOfHens) AS float)))/100)AS float) AS PoundsPerHundred
,CAST(IIF(NoOfHens = 0, 0,CONVERT(decimal(16,2),EggsProduced)/(CONVERT(decimal(16,2),NoOfHens) * 7.00)) AS DECIMAL(18,2)) AS PercentProduction
--,PercentProduction
,RTRIM(l.Location) + ' - ' + RTRIM(lh.LayerHouseName) AS display
,(BeginningInventory + TotalFeedDeliveries - FeedInventory) AS Consumption
FROM LayerHouseWeekly lhw
LEFT JOIN LayerHouse lh ON lh.LayerHouseID = lhw.LayerHouseID
LEFT JOIN Location l ON l.LocationID = lh.LocationID
WHERE LayerHouseWeeklyID = @LayerHouseWeeklyID


GO
