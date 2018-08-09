/****** Object:  StoredProcedure [dbo].[LayerHouseWeekly_Params]    Script Date: 6/19/2018 1:26:45 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[LayerHouseWeekly_Params]
GO
/****** Object:  StoredProcedure [dbo].[LayerHouseWeekly_Params]    Script Date: 6/19/2018 1:26:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseWeekly_Params]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LayerHouseWeekly_Params] AS' 
END
GO

--DROP PROC LayerHouseWeekly_Params
ALTER proc [dbo].[LayerHouseWeekly_Params]
AS


select convert(date,convert(date,GETDATE())) as weekEndDate
, convert(int,'') as LayerHouseID

GO
