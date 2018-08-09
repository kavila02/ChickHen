/****** Object:  StoredProcedure [dbo].[LayerHouseWeekly_Report]    Script Date: 7/31/2018 8:53:36 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseWeekly_Report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LayerHouseWeekly_Report]
GO
/****** Object:  StoredProcedure [dbo].[LayerHouseWeekly_Report]    Script Date: 7/31/2018 8:53:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseWeekly_Report]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LayerHouseWeekly_Report] AS' 
END
GO
ALTER PROC [dbo].[LayerHouseWeekly_Report]
@LayerHouseID int
AS

SELECT
lh.LayerHouseName
,lh.LayerHouseID
,lhw.WeekEndingDate
,lhw.NoOfHens
,f.FlockName
,lhw.Mortality
,lhw.HenWeight
,(CONVERT(varchar(max),CAST(lhw.LowTemp as int)) + '-' + CONVERT(varchar(max),cast (lhw.HiTemp as int))) AS LoHiTemp
,lhw.HiTemp
,lhw.LowTemp
,lhw.AmmoniaNh3
,lhw.LightProgram
,lhw.Rodents
,lhw.FlyCounts
,lhw.EggsProduced / 12 AS EggsProduced
,lhw.CaseWeight
,lhw.FeedInventory
,lhw.Water
,IIF(lhw.NoOfHens <= 0, 0,(lhw.Water / 7) / (lhw.NoOfHens / 100)) as w100
,lhw.BeginningInventory
,lhw.TotalFeedDeliveries
,lhw.PoundsPerHundred
,CAST(CAST(IIF(NoOfHens <= 0, NULL,CONVERT(decimal(16,2),EggsProduced)/(CONVERT(decimal(16,2),NoOfHens) * 7.00)) AS decimal(16,2)) * 100 AS int) AS PercentProduction
,lhw.Consumption
,loc.Location
,IIF(lhw.FeedInventory = 0, 0, CAST((CAST(lhw.Mortality AS float) / CAST(lhw.FeedInventory AS float)) * 100 AS Decimal(16,2))) AS PercentMort
,DATEDIFF(wk,HatchDate_First,lhw.WeekEndingDate) AS BirdAge
--,CAST((CONVERT(decimal(16,2),Water)/100) AS DECIMAL(16,2)) AS w100
,CAST((lhw.CaseWeight / 360) * lhw.PercentProduction AS decimal(16,2)) AS EgMs
,STUFF((SELECT ',' + a.Additive 
		FROM FlockAdditive fa
		JOIN Additive a ON a.AdditiveID = fa.AdditiveID
		WHERE fa.FlockID = f.FlockID
		ORDER BY a.SortOrder
	FOR XML PATH('')),1,1, '') AS Additives
,f.HousingDate_First AS 'HousingDate_Average'
,dbo.GetFourWeekBirdAverage (lhw.LayerHouseID,lhw.WeekEndingDate) AS '4w/100'
,CAST(IIF(lhw.EggsProduced = 0,0,CAST(lhw.Consumption as decimal(16,2)) / CAST(lhw.EggsProduced as decimal(16,2))) as decimal(16,2)) as 'Flb/Dz'
,f.TotalHoused
,CAST(IIF(f.TotalHoused = 0,0,(CAST(lhw.EggsProduced as decimal(16,2)) / 12) * (12 / cast(f.TotalHoused as decimal(16,2)))) as decimal(16,2)) as 'E/hh'
,pb.ProductBreed
FROM LayerHouseWeekly lhw
JOIN LayerHouse lh ON lh.LayerHouseID = lhw.LayerHouseID
JOIN Flock f ON f.LayerHouseID = lh.LayerHouseID AND f.FlockID =
 (SELECT TOP 1 FlockID FROM Flock WHERE GETDATE() between HousingDate_First and HousingOutDate AND LayerHouseID = f.LayerHouseID)
JOIN Location loc ON loc.LocationID = lh.LocationID
JOIN ProductBreed pb ON pb.ProductBreedID = f.ProductBreedID
WHERE lh.LayerHouseID = @LayerHouseID AND lhw.isActive = 1
ORDER BY lhw.LayerHouseID,lhw.WeekEndingDate

--EXEC LayerHouseWeekly_Report

GO
