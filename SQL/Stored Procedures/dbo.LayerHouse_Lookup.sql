/****** Object:  StoredProcedure [dbo].[LayerHouse_Lookup]    Script Date: 7/20/2018 10:35:12 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouse_Lookup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LayerHouse_Lookup]
GO
/****** Object:  StoredProcedure [dbo].[LayerHouse_Lookup]    Script Date: 7/20/2018 10:35:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouse_Lookup]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LayerHouse_Lookup] AS' 
END
GO

ALTER proc [dbo].[LayerHouse_Lookup]
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select rtrim(l.Location) + ' - ' + rtrim(LayerHouseName) as display
	,LayerHouseID
	,l.Location
	,IsNull(lh.SortOrder,0) as sortOrder
	,l.LocationID
from LayerHouse lh
inner join Location l on lh.LocationID = l.LocationID
--where Active = 1

union all
select '','','',-1,null
where @IncludeBlank = 1

union all
select 'All','','',-1,null
where @IncludeAll = 1

order by 4,3,1
GO
