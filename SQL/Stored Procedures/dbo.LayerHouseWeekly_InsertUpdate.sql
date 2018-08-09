/****** Object:  StoredProcedure [dbo].[LayerHouseWeekly_InsertUpdate]    Script Date: 7/31/2018 8:53:36 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseWeekly_InsertUpdate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LayerHouseWeekly_InsertUpdate]
GO
/****** Object:  StoredProcedure [dbo].[LayerHouseWeekly_InsertUpdate]    Script Date: 7/31/2018 8:53:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LayerHouseWeekly_InsertUpdate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[LayerHouseWeekly_InsertUpdate] AS' 
END
GO


--@I_vLayerHouseID is not a parameter for procedure LayerHouseDaily_InsertUpdate.


--SELECT * FROM LayerHouseDaily

ALTER proc [dbo].[LayerHouseWeekly_InsertUpdate]
	@I_vLayerHouseWeeklyID int
	,@I_vLayerHouseID int
	,@I_vWeekEndingDate varchar(255) = ''
	,@I_vBeginningInventory int = 0
	,@I_vHenWeight decimal(16,2)= 0
	,@I_vAmmoniaNh3 int = 0
	,@I_vLightProgram decimal(16,2) = 0
	,@I_vRodents int = 0
	,@I_vFlyCounts int = 0
	,@I_vCaseWeight decimal(16,2) = 0
	,@I_vFeedInventory int = 0
	,@I_vNoOfHens int = 0
	,@I_vBirdAge int = 0
	,@I_vPoundsPerHundred decimal(16, 2) = 0
	,@I_vPercentProduction decimal(16, 2) = 0
	,@I_vMortality int = 0
	,@I_vConsumption int = 0
	,@I_vLightIntensity decimal(16,2) = 0
	,@I_vPercentWeightUniformity decimal(16,2) = 0
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
		LightIntensity = @I_vLightIntensity,
		Rodents = @I_vRodents,
		FlyCounts = @I_vFlyCounts,
		CaseWeight = @I_vCaseWeight,
		FeedInventory = @I_vFeedInventory,
		NoOfHens = @I_vNoOfHens,
		BirdAge = @I_vBirdAge,
		Consumption = @I_vConsumption,
		PercentWeightUniformity = @I_vPercentWeightUniformity,
		isActive = 1
	where LayerHouseWeeklyID = @I_vLayerHouseWeeklyID
	AND WeekEndingDate = @I_vWeekEndingDate


	DECLARE @NextWeekEndDate AS Date
	SELECT @NextWeekEndDate = DATEADD(day,7,@I_vWeekEndingDate)

	EXEC dbo.LayerHouseWeekly_Create '',@I_vLayerHouseID, @NextWeekEndDate

	DECLARE @Mortality int = (SELECT Mortality FROM LayerHouseWeekly WHERE LayerHouseWeeklyID = @I_vLayerHouseWeeklyID)

	UPDATE LayerHouseWeekly
	SET 
	BeginningInventory = @I_vFeedInventory,
	NoOfHens = @I_vNoOfHens - @I_vMortality
	WHERE LayerHouseID = @I_vLayerHouseID
	AND WeekEndingDate = @NextWeekEndDate

	end

GO
