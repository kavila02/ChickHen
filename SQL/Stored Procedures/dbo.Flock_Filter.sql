/****** Object:  StoredProcedure [dbo].[Flock_Filter]    Script Date: 7/27/2018 3:17:03 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Flock_Filter]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Flock_Filter]
GO
/****** Object:  StoredProcedure [dbo].[Flock_Filter]    Script Date: 7/27/2018 3:17:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Flock_Filter]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[Flock_Filter] AS' 
END
GO

ALTER proc [dbo].[Flock_Filter]
@UserName nvarchar(255) = ''
AS

select @UserName as UserName
, convert(bit,0) as IncludeHistorical
, convert(bit,1) as IncludeCurrentFlock
, convert(bit,1) as IncludeLastFlockOrdered
, convert(bit,1) as IncludeInterimFlocks

GO
