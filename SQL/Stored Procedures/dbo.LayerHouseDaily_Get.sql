/****** Object:  StoredProcedure [dbo].[LayerHouseDaily_Get]    Script Date: 6/21/2018 8:03:32 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseDaily_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LayerHouseDaily_Get]
GO
/****** Object:  StoredProcedure [dbo].[LayerHouseDaily_Get]    Script Date: 6/21/2018 8:03:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseDaily_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LayerHouseDaily_Get] AS' 
END
GO

--DROP PROC LayerHouseDaily_Get
ALTER PROC [dbo].[LayerHouseDaily_Get]
(
@LayerHouseWeeklyID int
) 
AS


SELECT 
lhd.LayerHouseDailyID
,lhd.LayerHouseID
,lh.LayerHouseName
,LayerHouseWeeklyID
,CONVERT(varchar(255),DateOfRecord,1) AS DateOfRecord
,Mortality
,FeedDelivery
,DailyEggs
,Water
,MinTemp
,MaxTemp
,Chlorine
,RationCode
FROM LayerHouseDaily lhd
LEFT JOIN LayerHouse lh ON lh.LayerHouseID = lhd.LayerHouseID
WHERE LayerHouseWeeklyID = @LayerHouseWeeklyID



GO
