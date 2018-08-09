create proc LayerHouseWeekly_InsertUpdate
	@I_vLayerHouseWeeklyID int
	,@I_vLayerHouseID int
	,@I_vWeekEndingDate date
	,@I_vBeginningInventory int = ''
	,@I_vHenWeight int= ''
	,@I_vAmmoniaNh3 int = ''
	,@I_vLightProgram [decimal](4, 2) = ''
	,@I_vRodents int = ''
	,@I_vFlyCounts int = ''
	,@I_vCaseWeight int = ''
	,@I_vFeedInventory int = ''
	,@I_vNoOfHens int = ''
	--,@I_vBirdAge int = ''
	,@I_vPoundsPerHundred int = ''
	,@I_vPercentProduction int = ''
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

	if @I_vLayerHouseID <> 0
	begin
	update LayerHouseWeekly
	set
		LayerHouseID = @I_vLayerHouseID,
		WeekEndingDate = @I_vWeekEndingDate,
		BeginningInventory = @I_vBeginningInventory,
		HenWeight = @I_vHenWeight,
		AmmoniaNh3 = @I_vAmmoniaNh3,
		LightProgram = @I_vLightProgram,
		Rodents = @I_vRodents,
		FlyCounts = @I_vFlyCounts,
		CaseWeight = @I_vCaseWeight,
		FeedInventory = @I_vFeedInventory,
		NoOfHens = @I_vNoOfHens,
		--BirdAge = @I_vBirdAge,
		PoundsPerHundred = @I_vPoundsPerHundred,
		PercentProduction = @I_vPercentProduction
	where LayerHouseWeeklyID = @I_vLayerHouseWeeklyID
	AND WeekEndingDate = @I_vWeekEndingDate
	end


GO
