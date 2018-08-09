/****** Object:  StoredProcedure [dbo].[Flock_InsertUpdate]    Script Date: 7/27/2018 3:17:03 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Flock_InsertUpdate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Flock_InsertUpdate]
GO
/****** Object:  StoredProcedure [dbo].[Flock_InsertUpdate]    Script Date: 7/27/2018 3:17:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Flock_InsertUpdate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[Flock_InsertUpdate] AS' 
END
GO


ALTER proc [dbo].[Flock_InsertUpdate]
	@I_vFlockID int
	,@I_vFlockName nvarchar(255) = 'New'
	,@I_vLayerHouseID int = null
	,@I_vProductBreedID int = null
	,@I_vQuantity nvarchar(20) = null
	,@I_vServicesNotes nvarchar(1000) = ''
	,@I_vFlockNumber varchar(15) = ''
	--,@I_vNPIP varchar(50) = ''
	,@I_vOldOutDate date = null
	,@I_vPulletsMovedID int = null
	,@I_vNumberChicksOrdered nvarchar(20) = null
	,@I_vOldFowlHatchDate date = null
	,@I_vServiceTechID int = null
	,@I_vTotalHoused nvarchar(20) = null
	,@I_vHousingOutDate date = null
	,@I_vFowlRemoved bit = 0
	,@I_vFowlOutID int = null
	,@I_vHatchDate_First date = null
	,@I_vHatchDate_Last date = null
	,@I_vHatchDate_Average date = null
	,@I_vHousingDate_First date = null
	,@I_vHousingDate_Last date = null
	,@I_vHousingDate_Average date = null
	,@I_vLastPulletWeight decimal(16,2) = null

	,@I_vHatcheryID int = null
	,@I_vChickPlacementDate date = null
	,@I_vTotalChicksPlaced nvarchar(20) = null

	,@I_vPulletHousingTransConfirmNumber nvarchar(50) = null
	,@I_vFowlOutTransConfirmNumber nvarchar(50) = null

	,@I_vOrderNumber varchar(50) = ''
	,@I_vUserName nvarchar(255) = ''
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

declare @LocationAbbreviation nvarchar(50)
select @LocationAbbreviation = rtrim(LocationAbbreviation) + rtrim(replace(lh.LayerHouseName,'-',''))
from Location l
inner join LayerHouse lh on l.LocationID = lh.LocationID
where lh.LayerHouseID = @I_vLayerHouseID

select @I_vFlockName = IsNull(@LocationAbbreviation,'') + IsNull(replace(convert(nvarchar,@I_vHatchDate_First,101),'/',''),'')

declare @updateNextFlock bit = 0
--If Hatch Date or Housing Date or housing out date have changed, we need to update the next flock's info
If ((select HatchDate_Average from Flock where FlockID = @I_vFlockID) <> @I_vHatchDate_Average
	or (select HousingDate_Average from Flock where FlockID = @I_vFlockID) <> @I_vHousingDate_Average
	or (select HousingOutDate from Flock where FlockID = @I_vFlockID) <> @I_vHousingOutDate)
	and IsNull(@I_vLayerHouseID,'') <> ''
begin
	select @updateNextFlock = 1
end

if @I_vFlockID = 0
begin
	declare @FlockID table (FlockID int)
	insert into Flock (
		
		FlockName
		, LayerHouseID
		, ProductBreedID
		, Quantity
		, ServicesNotes
		--, FlockNumber
		--, NPIP
		, OldOutDate
		, PulletsMovedID
		, NumberChicksOrdered
		, OldFowlHatchDate
		, ServiceTechID
		, TotalHoused
		, HousingOutDate
		, FowlRemoved
		, FowlOutID
		, HatchDate_First
		, HatchDate_Last
		, HatchDate_Average
		, HousingDate_First
		, HousingDate_Last
		, HousingDate_Average
		,HatcheryID
		,ChickPlacementDate
		,TotalChicksPlaced
		,PulletHousingTransConfirmNumber
		,FowlOutTransConfirmNumber
		, OrderNumber
		, LastPulletWeight
	)
	output inserted.FlockID into @FlockID(FlockID)
	select
		
		@I_vFlockName
		,@I_vLayerHouseID
		,@I_vProductBreedID
		,convert(int,dbo.csiStripNonNumericFromString(@I_vQuantity))
		,@I_vServicesNotes
		--,@I_vFlockNumber
		--,@I_vNPIP
		,@I_vOldOutDate
		,@I_vPulletsMovedID
		,convert(int,dbo.csiStripNonNumericFromString(@I_vNumberChicksOrdered))
		,@I_vOldFowlHatchDate
		,@I_vServiceTechID
		,convert(int,dbo.csiStripNonNumericFromString(@I_vTotalHoused))
		,@I_vHousingOutDate
		,@I_vFowlRemoved
		,@I_vFowlOutID
		,@I_vHatchDate_First
		,@I_vHatchDate_Last
		,@I_vHatchDate_Average
		,@I_vHousingDate_First
		,@I_vHousingDate_Last
		,@I_vHousingDate_Average
		,@I_vHatcheryID
		,@I_vChickPlacementDate
		,convert(int,dbo.csiStripNonNumericFromString(@I_vTotalChicksPlaced))
		,@I_vPulletHousingTransConfirmNumber
		,@I_vFowlOutTransConfirmNumber
		,@I_vOrderNumber
		,@I_vLastPulletWeight
	select top 1 @I_vFlockID = FlockID, @iRowID = FlockID from @FlockID
end
else
begin
	declare @HatchDate_Average_stored date
			,@HatchDate_First_stored date
			,@HatchDate_Last_stored date
			,@HousingDate_Average_stored date
			,@HousingDate_First_stored date
			,@HousingDate_Last_stored date
			,@HousingOutDate_stored date
			,@OldFowlHatchDate_stored date
			,@OldOutDate_stored date
			,@ChickPlacementDate_stored date

	select @HatchDate_Average_stored = HatchDate_Average
			,@HatchDate_First_stored = HatchDate_First
			,@HatchDate_Last_stored = HatchDate_Last
			,@HousingDate_Average_stored = HousingDate_Average
			,@HousingDate_First_stored = HousingDate_First
			,@HousingDate_Last_stored = HousingDate_Last
			,@HousingOutDate_stored = HousingOutDate
			,@OldFowlHatchDate_stored = OldFowlHatchDate
			,@OldOutDate_stored = OldOutDate
			,@ChickPlacementDate_stored = ChickPlacementDate
		From Flock where FlockID = @I_vFlockID

	update Flock
	set
		
		FlockName = @I_vFlockName
		,LayerHouseID = @I_vLayerHouseID
		,ProductBreedID = @I_vProductBreedID
		,Quantity = convert(int,dbo.csiStripNonNumericFromString(@I_vQuantity))
		,ServicesNotes = @I_vServicesNotes
		,FlockNumber = @I_vFlockNumber
		--,NPIP = @I_vNPIP
		,OldOutDate = @I_vOldOutDate
		,PulletsMovedID = @I_vPulletsMovedID
		,NumberChicksOrdered = convert(int,dbo.csiStripNonNumericFromString(@I_vNumberChicksOrdered))
		,OldFowlHatchDate = @I_vOldFowlHatchDate
		,ServiceTechID = @I_vServiceTechID
		,TotalHoused = convert(int,dbo.csiStripNonNumericFromString(@I_vTotalHoused))
		,HousingOutDate = @I_vHousingOutDate
		,FowlRemoved = @I_vFowlRemoved
		,FowlOutID = @I_vFowlOutID
		,HatchDate_First = @I_vHatchDate_First
		,HatchDate_Last = @I_vHatchDate_Last
		,HatchDate_Average = @I_vHatchDate_Average
		,HousingDate_First = @I_vHousingDate_First
		,HousingDate_Last = @I_vHousingDate_Last
		,HousingDate_Average = @I_vHousingDate_Average
		,LastPulletWeight = @I_vLastPulletWeight

		,HatcheryID = @I_vHatcheryID
		,ChickPlacementDate = @I_vChickPlacementDate
		,TotalChicksPlaced = convert(int,dbo.csiStripNonNumericFromString(@I_vTotalChicksPlaced))
		
		,PulletHousingTransConfirmNumber = @I_vPulletHousingTransConfirmNumber
		,FowlOutTransConfirmNumber = @I_vFowlOutTransConfirmNumber

		,OrderNumber = @I_vOrderNumber
	where @I_vFlockID = FlockID
	select @iRowID = @I_vFlockID


	--update any dates that reference changed dates
	if @HatchDate_Average_stored <> @I_vHatchDate_Average
	begin
		exec CalculateDateOfAction_FieldReferenceUpdate @TableName = 'Flock', @FieldName = 'HatchDate_Average', @TableID = @I_vFlockID
	end

	if @HatchDate_First_stored <> @I_vHatchDate_First
	begin
		exec CalculateDateOfAction_FieldReferenceUpdate @TableName = 'Flock', @FieldName = 'HatchDate_First', @TableID = @I_vFlockID
	end

	if @HatchDate_Last_stored <> @I_vHatchDate_Last
	begin
		exec CalculateDateOfAction_FieldReferenceUpdate @TableName = 'Flock', @FieldName = 'HatchDate_Last', @TableID = @I_vFlockID
	end

	if @HousingDate_Average_stored <> @I_vHousingDate_Average
	begin
		exec CalculateDateOfAction_FieldReferenceUpdate @TableName = 'Flock', @FieldName = 'HousingDate_Average', @TableID = @I_vFlockID
	end

	if @HousingDate_First_stored <> @I_vHousingDate_First
	begin
		exec CalculateDateOfAction_FieldReferenceUpdate @TableName = 'Flock', @FieldName = 'HousingDate_First', @TableID = @I_vFlockID
	end

	if @HousingDate_Last_stored <> @I_vHousingDate_Last
	begin
		exec CalculateDateOfAction_FieldReferenceUpdate @TableName = 'Flock', @FieldName = 'HousingDate_Last', @TableID = @I_vFlockID
	end

	if @HousingOutDate_stored <> @I_vHousingOutDate
	begin
		exec CalculateDateOfAction_FieldReferenceUpdate @TableName = 'Flock', @FieldName = 'HousingOutDate', @TableID = @I_vFlockID
	end

	if @OldFowlHatchDate_stored <> @I_vOldFowlHatchDate
	begin
		exec CalculateDateOfAction_FieldReferenceUpdate @TableName = 'Flock', @FieldName = 'OldFowlHatchDate', @TableID = @I_vFlockID
	end

	if @OldOutDate_stored <> @I_vOldOutDate
	begin
		exec CalculateDateOfAction_FieldReferenceUpdate @TableName = 'Flock', @FieldName = 'OldOutDate', @TableID = @I_vFlockID
	end

	if @ChickPlacementDate_stored <> @I_vChickPlacementDate
	begin
		exec CalculateDateOfAction_FieldReferenceUpdate @TableName = 'Flock', @FieldName = 'ChickPlacementDate', @TableID = @I_vFlockID
	end

end

if @updateNextFlock = 1
begin

	declare @nextFlockID int
	select top 1 @nextFlockID = FlockID 
		from Flock f2 
		where f2.LayerHouseID = @I_vLayerHouseID and f2.HousingDate_First > @I_vHousingDate_First 
		order by f2.HousingDate_First

	update Flock
	set OldFowlHatchDate = @I_vHatchDate_Average
			,OldOutDate = @I_vHousingOutDate
		from Flock f
		where f.FlockID = @nextFlockID

end



select @I_vFlockID as ID,'forward' As referenceType
GO
