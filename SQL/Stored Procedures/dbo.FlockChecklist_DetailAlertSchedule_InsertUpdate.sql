create proc FlockChecklist_DetailAlertSchedule_InsertUpdate
	@I_vFlockChecklist_DetailAlertScheduleID int
	,@I_vFlockChecklist_DetailID int
	,@I_vAlertDescription nvarchar(255) = ''
	,@I_vAlertTemplateID int = null
	,@I_vTimeFromStep int = 0
	,@I_vTimeFromStep_DatePartID varchar(4) = null
	,@I_vStartDateOrEndDate smallint = 0
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vFlockChecklist_DetailAlertScheduleID = 0
begin
	declare @FlockChecklist_DetailAlertScheduleID table (FlockChecklist_DetailAlertScheduleID int)
	insert into FlockChecklist_DetailAlertSchedule (
		
		FlockChecklist_DetailID
		, AlertDescription
		, AlertTemplateID
		, TimeFromStep
		, TimeFromStep_DatePartID
		, StartDateOrEndDate
	)
	output inserted.FlockChecklist_DetailAlertScheduleID into @FlockChecklist_DetailAlertScheduleID(FlockChecklist_DetailAlertScheduleID)
	select
		
		@I_vFlockChecklist_DetailID
		,@I_vAlertDescription
		,@I_vAlertTemplateID
		,@I_vTimeFromStep
		,@I_vTimeFromStep_DatePartID
		,@I_vStartDateOrEndDate
	select top 1 @I_vFlockChecklist_DetailAlertScheduleID = FlockChecklist_DetailAlertScheduleID, @iRowID = FlockChecklist_DetailAlertScheduleID from @FlockChecklist_DetailAlertScheduleID
end
else
begin
	update FlockChecklist_DetailAlertSchedule
	set
		
		FlockChecklist_DetailID = @I_vFlockChecklist_DetailID
		,AlertDescription = @I_vAlertDescription
		,AlertTemplateID = @I_vAlertTemplateID
		,TimeFromStep = @I_vTimeFromStep
		,TimeFromStep_DatePartID = @I_vTimeFromStep_DatePartID
		,StartDateOrEndDate = @I_vStartDateOrEndDate
	where @I_vFlockChecklist_DetailAlertScheduleID = FlockChecklist_DetailAlertScheduleID
	select @iRowID = @I_vFlockChecklist_DetailAlertScheduleID
end