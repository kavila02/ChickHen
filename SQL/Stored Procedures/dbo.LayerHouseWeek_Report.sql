/****** Object:  StoredProcedure [dbo].[LayerHouseWeek_Report]    Script Date: 6/21/2018 8:03:32 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseWeek_Report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LayerHouseWeek_Report]
GO
/****** Object:  StoredProcedure [dbo].[LayerHouseWeek_Report]    Script Date: 6/21/2018 8:03:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseWeek_Report]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LayerHouseWeek_Report] AS' 
END
GO

ALTER proc [dbo].[LayerHouseWeek_Report]
	@reportDate date = null
AS
select @reportDate = IsNull(NullIf(@reportDate,''),GETDATE())

if DATEPART(dw,@reportDate) <> 1
SET @reportDate = DATEADD([day], ((DATEDIFF([day], '19000107', @reportDate) / 7) * 7), '19000107')

SELECT 
lh.LayerHouseName
,lhw.NoOfHens
,lhw.BirdAge
,f.FlockName
,lhw.Mortality
,lhw.HenWeight
,lhw.HiTemp
,lhw.LowTemp
,lhw.AmmoniaNh3
,lhw.LightProgram
,lhw.Rodents
,lhw.FlyCounts
,lhw.EggsProduced
,lhw.CaseWeight
,lhw.FeedInventory
,lhw.Water
,lhw.BeginningInventory
,lhw.TotalFeedDeliveries
,lhw.PoundsPerHundred
,lhw.PercentProduction
,lhw.Consumption
FROM LayerHouseWeekly lhw
JOIN LayerHouse lh ON lh.LayerHouseID = lhw.LayerHouseID
LEFT JOIN Flock f ON f.LayerHouseID = lh.LayerHouseID AND f.FlockID =
 (SELECT TOP 1 FlockID FROM Flock WHERE GETDATE() between HousingDate_First and HousingOutDate AND LayerHouseID = f.LayerHouseID)
WHERE WeekEndingDate = @reportDate


GO
