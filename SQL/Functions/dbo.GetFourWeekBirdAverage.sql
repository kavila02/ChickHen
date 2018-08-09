/****** Object:  UserDefinedFunction [dbo].[GetFourWeekBirdAverage]    Script Date: 7/19/2018 8:41:54 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetFourWeekBirdAverage]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[GetFourWeekBirdAverage]
GO
/****** Object:  UserDefinedFunction [dbo].[GetFourWeekBirdAverage]    Script Date: 7/19/2018 8:41:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetFourWeekBirdAverage]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[GetFourWeekBirdAverage] (@LayerHouseID int, @Date Date)
RETURNS Decimal(18,2)
AS 
BEGIN
DECLARE @BeginDate date = (SELECT DATEADD(week,-3,@Date))

DECLARE @Result Decimal(16,2) =
(SELECT
AVG(ISNULL(CAST(Consumption as Decimal(16,2)),0.00))
FROM LayerHouseWeekly lhw
WHERE 
LayerHouseID = @LayerHouseID
AND WeekEndingDate BETWEEN @BeginDate AND @Date)

RETURN @Result

END
' 
END
GO
