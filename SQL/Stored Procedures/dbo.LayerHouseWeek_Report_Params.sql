/****** Object:  StoredProcedure [dbo].[LayerHouseWeek_Report_Params]    Script Date: 6/19/2018 1:26:45 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[LayerHouseWeek_Report_Params]
GO
/****** Object:  StoredProcedure [dbo].[LayerHouseWeek_Report_Params]    Script Date: 6/19/2018 1:26:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseWeek_Report_Params]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LayerHouseWeek_Report_Params] AS' 
END
GO

ALTER proc [dbo].[LayerHouseWeek_Report_Params]
AS

select convert(date,GETDATE()) as reportDate
GO
