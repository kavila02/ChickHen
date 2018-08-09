create proc LayerHouse_InsertUpdate
	@I_vLayerHouseID int
	,@I_vLocationID int = null
	,@I_vLayerHouseName nvarchar(255) = ''
	,@I_vYearBuilt nvarchar(50) = ''
	,@I_vHouseStyle nvarchar(255) = ''
	,@I_vCageHeight varchar(255) = null
	,@I_vCageWidth varchar(255) = null
	,@I_vCageDepth varchar(255) = null
	,@I_vCageSizeNotes nvarchar(255)  = ''
	,@I_vCubicInchesInCage varchar(255) = null
	,@I_vSquareInchesInCage varchar(255) = null
	,@I_vNumberCages varchar(255) = null
	,@I_vDrinkersPerCage varchar(20) = null
	,@I_vBirdCapacity varchar(20) = null
	,@I_vBirdCapacityBrown varchar(20) = null
	,@I_vPEQAPNumber varchar(50) = null
	,@I_vBirdsPerHouse varchar(20) = null
	,@I_vSortOrder int = null
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vLayerHouseID = 0
begin
	insert into LayerHouse (
		
		LocationID
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
		, DrinkersPerCage
		, BirdCapacity
		, BirdCapacityBrown
		, PEQAPNumber
		, BirdsPerHouse
		, SortOrder
	)
	select
		
		@I_vLocationID
		,@I_vLayerHouseName
		,@I_vYearBuilt
		,@I_vHouseStyle
		,@I_vCageHeight
		,@I_vCageWidth
		,@I_vCageDepth
		,@I_vCageSizeNotes
		,@I_vCubicInchesInCage
		,@I_vSquareInchesInCage
		,@I_vNumberCages
		,convert(int,dbo.csiStripNonNumericFromString(@I_vDrinkersPerCage))
		,convert(int,dbo.csiStripNonNumericFromString(@I_vBirdCapacity))
		,convert(int,dbo.csiStripNonNumericFromString(@I_vBirdCapacityBrown))
		,@I_vPEQAPNumber
		,convert(numeric(19,1),dbo.StripOutMoneyFormat(@I_vBirdsPerHouse))
		,@I_vSortOrder
	select @I_vLayerHouseID = SCOPE_IDENTITY()
end
else
begin
	update LayerHouse
	set
		
		LocationID = @I_vLocationID
		,LayerHouseName = @I_vLayerHouseName
		,YearBuilt = @I_vYearBuilt
		,HouseStyle = @I_vHouseStyle
		,CageHeight = @I_vCageHeight
		,CageWidth = @I_vCageWidth
		,CageDepth = @I_vCageDepth
		,CageSizeNotes = @I_vCageSizeNotes
		,CubicInchesInCage = @I_vCubicInchesInCage
		,SquareInchesInCage = @I_vSquareInchesInCage
		,NumberCages = @I_vNumberCages
		,DrinkersPerCage = convert(int,dbo.csiStripNonNumericFromString(@I_vDrinkersPerCage))
		,BirdCapacity = convert(int,dbo.csiStripNonNumericFromString(@I_vBirdCapacity))
		,BirdCapacityBrown = convert(int,dbo.csiStripNonNumericFromString(@I_vBirdCapacityBrown))
		,PEQAPNumber = @I_vPEQAPNumber
		,BirdsPerHouse = convert(numeric(19,1),dbo.StripOutMoneyFormat(@I_vBirdsPerHouse))
		,SortOrder = @I_vSortOrder
	where @I_vLayerHouseID = LayerHouseID
end

select @I_vLayerHouseID as ID,'forward' As referenceType
GO
