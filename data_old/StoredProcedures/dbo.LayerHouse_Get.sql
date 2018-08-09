create proc LayerHouse_Get
@LayerHouseID int = null
,@IncludeNew bit = 0
As

select
	LayerHouseID
	, LocationID
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
	, SortOrder
from LayerHouse
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
where @IncludeNew = 1 or @LayerHouseID = 0
order by SortOrder
GO
