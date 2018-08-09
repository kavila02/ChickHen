/****** Object:  StoredProcedure [dbo].[LayerHouse_Get]    Script Date: 6/19/2018 1:26:45 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[LayerHouse_Get]
GO
/****** Object:  StoredProcedure [dbo].[LayerHouse_Get]    Script Date: 6/19/2018 1:26:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouse_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LayerHouse_Get] AS' 
END
GO

ALTER proc [dbo].[LayerHouse_Get]
@LayerHouseID int = null
,@IncludeNew bit = 0
As

select
	LayerHouseID
	, lh.LocationID
	, LayerHouseName
	, YearBuilt
	, HouseStyle
	, CageHeight
	, CageWidth
	, CageDepth
	, CageSizeNotes
	, CubicInchesInCage
	, SquareInchesInCage
	, NumberCages
	, dbo.FormatIntComma(DrinkersPerCage) as DrinkersPerCage
	, dbo.FormatIntComma(BirdCapacity) as BirdCapacity
	, dbo.FormatIntComma(BirdCapacityBrown) as BirdCapacityBrown
	, PEQAPNumber
	, dbo.FormatNumeric191(BirdsPerHouse) as BirdsPerHouse
	, lh.SortOrder
	,l.Location
from LayerHouse lh
left join Location l ON l.LocationID = lh.LocationID
where IsNull(@LayerHouseID,LayerHouseID) = LayerHouseID
union all
select
	LayerHouseID = convert(int,0)
	, LocationID = convert(int,null)
	, LayerHouseName = convert(nvarchar(255),null)
	, YearBuilt = convert(nvarchar(50),null)
	, HouseStyle = convert(nvarchar(255),null)
	, CageHeight = convert(varchar(255),null)
	, CageWidth = convert(varchar(255),null)
	, CageDepth = convert(varchar(255),null)
	, CageSizeNotes = convert(nvarchar(255),null)
	, CubicInchesInCage = convert(varchar(255),null)
	, SquareInchesInCage = convert(varchar(255),null)
	, NumberCages = convert(varchar(255),null)
	, DrinkersPerCage = convert(varchar(20),null)
	, BirdCapacity = convert(varchar(20),null)
	, BirdCapacityBrown = convert(varchar(20),null)
	, PEQAPNumber = convert(varchar(50),'')
	, BirdsPerHouse = convert(varchar(20),null)
	, SortOrder = convert(int,null)
	, Location = convert(nvarchar(255),null)
where @IncludeNew = 1 or @LayerHouseID = 0
order by SortOrder
