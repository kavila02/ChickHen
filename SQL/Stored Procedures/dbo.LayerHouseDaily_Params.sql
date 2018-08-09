/****** Object:  StoredProcedure [dbo].[LayerHouseDaily_Params]    Script Date: 6/19/2018 1:26:45 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[LayerHouseDaily_Params]
GO
/****** Object:  StoredProcedure [dbo].[LayerHouseDaily_Params]    Script Date: 6/19/2018 1:26:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseDaily_Params]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LayerHouseDaily_Params] AS' 
END
GO


--DROP PROC LayerHouseWeekly_Params
ALTER proc [dbo].[LayerHouseDaily_Params]
@rowID AS int
AS

select convert(date,WeekEndingDate) as weekEndDate
, convert(int,LayerHouseID) as LayerHouseID
FROM LayerHouseWeekly
WHERE LayerHouseWeeklyID = @rowID

GO
