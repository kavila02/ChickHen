

create proc FlockChecklist_Detail_InsertUpdate
	@I_vFlockChecklist_DetailID int
	,@I_vFlockChecklistID int
	,@I_vStepName nvarchar(255) = ''
	,@I_vStepOrder int = null
	,@I_vActionDescription nvarchar(500) = ''

	,@I_vStepOrFieldCalculation smallint = null
	,@I_vDateOfAction_TimeFromStep int = null
	,@I_vTimeFromStep_DatePartID varchar(4) = null
	,@I_vDateOfAction_FlockChecklist_DetailID int = null
	,@I_vDateOfAction_TimeFromField int = null
	,@I_vTimeFromField_DatePartID varchar(4) = null
	,@I_vDateOfAction_FieldReferenceID int = null
	
	,@I_vStepOrFieldCalculation_EndDate smallint = null
	,@I_vDateOfAction_TimeFromStep_EndDate int = null
	,@I_vTimeFromStep_DatePartID_EndDate varchar(4) = null
	,@I_vDateOfAction_FlockChecklist_DetailID_EndDate int = null
	,@I_vDateOfAction_TimeFromField_EndDate int = null
	,@I_vTimeFromField_DatePartID_EndDate varchar(4) = null
	,@I_vDateOfAction_FieldReferenceID_EndDate int = null

	,@I_vOriginatorID int = null
	,@I_vDetailedNotes nvarchar(4000) = ''
	,@I_vDetail_StatusID int = null
	,@I_vDateOfAction date = null
	,@I_vDateOfAction_EndDate date = null
	,@I_vCompletedByID int = null
	,@I_vCompletedDate date = null
	,@I_vChecklist_DetailTypeID int = null
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


if @I_vFlockChecklist_DetailID = 0
begin
	if @I_vStepOrder is null
		select @I_vStepOrder = convert(int,IsNull((Select MAX(StepOrder) + 1 from FlockChecklist_Detail where FlockChecklistID = @I_vFlockChecklistID),1))

	declare @FlockChecklist_DetailID table (FlockChecklist_DetailID int)
	insert into FlockChecklist_Detail (
		
		FlockChecklistID
		, StepName
		, StepOrder
		, ActionDescription

		, StepOrFieldCalculation
		, DateOfAction_TimeFromStep
		, TimeFromStep_DatePartID
		, DateOfAction_FlockChecklist_DetailID
		, DateOfAction_TimeFromField
		, TimeFromField_DatePartID
		, DateOfAction_FieldReferenceID
		
		, StepOrFieldCalculation_EndDate
		, DateOfAction_TimeFromStep_EndDate
		, TimeFromStep_DatePartID_EndDate
		, DateOfAction_FlockChecklist_DetailID_EndDate
		, DateOfAction_TimeFromField_EndDate
		, TimeFromField_DatePartID_EndDate
		, DateOfAction_FieldReferenceID_EndDate

		, OriginatorID
		, DetailedNotes
		, Detail_StatusID
		, DateOfAction
		, DateOfAction_EndDate
		, CompletedByID
		, CompletedDate
		, Checklist_DetailTypeID
	)
	output inserted.FlockChecklist_DetailID into @FlockChecklist_DetailID(FlockChecklist_DetailID)
	select
		
		@I_vFlockChecklistID
		,@I_vStepName
		,@I_vStepOrder
		,@I_vActionDescription

		,@I_vStepOrFieldCalculation
		,@I_vDateOfAction_TimeFromStep
		,@I_vTimeFromStep_DatePartID
		,@I_vDateOfAction_FlockChecklist_DetailID
		,@I_vDateOfAction_TimeFromField
		,@I_vTimeFromField_DatePartID
		,@I_vDateOfAction_FieldReferenceID

		,@I_vStepOrFieldCalculation_EndDate
		,@I_vDateOfAction_TimeFromStep_EndDate
		,@I_vTimeFromStep_DatePartID_EndDate
		,@I_vDateOfAction_FlockChecklist_DetailID_EndDate
		,@I_vDateOfAction_TimeFromField_EndDate
		,@I_vTimeFromField_DatePartID_EndDate
		,@I_vDateOfAction_FieldReferenceID_EndDate

		,@I_vOriginatorID
		,@I_vDetailedNotes
		,@I_vDetail_StatusID
		,@I_vDateOfAction
		,@I_vDateOfAction_EndDate
		,@I_vCompletedByID
		,@I_vCompletedDate
		,@I_vChecklist_DetailTypeID
	select top 1 @I_vFlockChecklist_DetailID = FlockChecklist_DetailID, @iRowID = FlockChecklist_DetailID from @FlockChecklist_DetailID
end
else
begin

	update FlockChecklist_Detail
	set
		
		FlockChecklistID = @I_vFlockChecklistID
		,StepName = @I_vStepName
		,StepOrder = @I_vStepOrder
		,ActionDescription = @I_vActionDescription

		,StepOrFieldCalculation = @I_vStepOrFieldCalculation
		,DateOfAction_TimeFromStep = @I_vDateOfAction_TimeFromStep
		,TimeFromStep_DatePartID = @I_vTimeFromStep_DatePartID
		,DateOfAction_FlockChecklist_DetailID = @I_vDateOfAction_FlockChecklist_DetailID
		,DateOfAction_TimeFromField = @I_vDateOfAction_TimeFromField
		,TimeFromField_DatePartID = @I_vTimeFromField_DatePartID
		,DateOfAction_FieldReferenceID = @I_vDateOfAction_FieldReferenceID

		,StepOrFieldCalculation_EndDate = @I_vStepOrFieldCalculation_EndDate
		,DateOfAction_TimeFromStep_EndDate = @I_vDateOfAction_TimeFromStep_EndDate
		,TimeFromStep_DatePartID_EndDate = @I_vTimeFromStep_DatePartID_EndDate
		,DateOfAction_FlockChecklist_DetailID_EndDate = @I_vDateOfAction_FlockChecklist_DetailID_EndDate
		,DateOfAction_TimeFromField_EndDate = @I_vDateOfAction_TimeFromField_EndDate
		,TimeFromField_DatePartID_EndDate = @I_vTimeFromField_DatePartID_EndDate
		,DateOfAction_FieldReferenceID_EndDate = @I_vDateOfAction_FieldReferenceID_EndDate

		,OriginatorID = @I_vOriginatorID
		,DetailedNotes = @I_vDetailedNotes
		,Detail_StatusID = @I_vDetail_StatusID
		,DateOfAction = @I_vDateOfAction
		,DateOfAction_EndDate = @I_vDateOfAction_EndDate
		,CompletedByID = @I_vCompletedByID
		,CompletedDate = @I_vCompletedDate
		,Checklist_DetailTypeID = @I_vChecklist_DetailTypeID
	where @I_vFlockChecklist_DetailID = FlockChecklist_DetailID
	select @iRowID = @I_vFlockChecklist_DetailID

	--recalc current date if necessary
	--Date Based on Step
	if @I_vStepOrFieldCalculation = 1 or @I_vStepOrFieldCalculation_EndDate = 1
	begin
		exec CalculateDateOfAction_StepUpdate @FlockChecklist_DetailID = @I_vDateOfAction_FlockChecklist_DetailID, @NestLevel = 1
	end
	--Date Based on Field
	if @I_vStepOrFieldCalculation = 2
	begin
		declare @FieldName nvarchar(255), @FlockID int
		select @FieldName = FieldName from FieldReference where FieldReferenceID = @I_vDateOfAction_FieldReferenceID
		select @FlockID = FlockID from FlockChecklist where FlockChecklistID = @I_vFlockChecklistID
		exec CalculateDateOfAction_FieldReferenceUpdate @TableName = 'Flock', @FieldName = @FieldName, @TableID = @FlockID
	end	
	if @I_vStepOrFieldCalculation_EndDate = 2
	begin
		declare @FieldName_EndDate nvarchar(255), @FlockID_EndDate int
		select @FieldName_EndDate = FieldName from FieldReference where FieldReferenceID = @I_vDateOfAction_FieldReferenceID_EndDate
		select @FlockID_EndDate = FlockID from FlockChecklist where FlockChecklistID = @I_vFlockChecklistID
		exec CalculateDateOfAction_FieldReferenceUpdate @TableName = 'Flock', @FieldName = @FieldName_EndDate, @TableID = @FlockID_EndDate
	end	
end

--update any dates referencing this one (and so on down the tree)
exec CalculateDateOfAction_StepUpdate @FlockChecklist_DetailID = @I_vFlockChecklist_DetailID, @NestLevel = 1

select @I_vFlockChecklist_DetailID as FlockChecklist_DetailID, @I_vFlockChecklistID As FlockChecklistID, 'forward' As referenceType