create proc ChecklistTemplate_Detail_InsertUpdate
	@I_vChecklistTemplate_DetailID int
	,@I_vChecklistTemplateID int
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
	,@I_vDefaultDetail_StatusID int = null
	,@I_vChecklist_DetailTypeID int = null
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


if @I_vChecklistTemplate_DetailID = 0
begin
	if @I_vStepOrder is null
		select @I_vStepOrder = convert(int,IsNull((Select MAX(StepOrder) + 1 from ChecklistTemplate_Detail where ChecklistTemplateID = @I_vChecklistTemplateID),1))

	declare @ChecklistTemplate_DetailID table (ChecklistTemplate_DetailID int)
	insert into ChecklistTemplate_Detail (
		
		ChecklistTemplateID
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
		, DefaultDetail_StatusID
		,Checklist_DetailTypeID
	)
	output inserted.ChecklistTemplate_DetailID into @ChecklistTemplate_DetailID(ChecklistTemplate_DetailID)
	select
		
		@I_vChecklistTemplateID
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
		,@I_vDefaultDetail_StatusID
		,@I_vChecklist_DetailTypeID
	select top 1 @I_vChecklistTemplate_DetailID = ChecklistTemplate_DetailID, @iRowID = ChecklistTemplate_DetailID from @ChecklistTemplate_DetailID
end
else
begin
	update ChecklistTemplate_Detail
	set
		
		ChecklistTemplateID = @I_vChecklistTemplateID
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
		,DefaultDetail_StatusID = @I_vDefaultDetail_StatusID
		,Checklist_DetailTypeID = @I_vChecklist_DetailTypeID
	where @I_vChecklistTemplate_DetailID = ChecklistTemplate_DetailID
	select @iRowID = @I_vChecklistTemplate_DetailID
end

select @I_vChecklistTemplate_DetailID as ChecklistTemplate_DetailID, @I_vChecklistTemplateID As ChecklistTemplateID, 'forward' As referenceType