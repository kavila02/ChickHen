if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_DetailAlertSchedule_InsertUpdate' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_DetailAlertSchedule_InsertUpdate
end
GO
create proc ChecklistTemplate_DetailAlertSchedule_InsertUpdate
	@I_vChecklistTemplate_DetailAlertScheduleID int
	,@I_vChecklistTemplate_DetailID int
	,@I_vAlertDescription nvarchar(255) = ''
	,@I_vAlertTemplateID int = null
	,@I_vTimeFromStep int = 0
	,@I_vTimeFromStep_DatePartID varchar(4) = null
	,@I_vStartDateOrEndDate smallint = 0
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vChecklistTemplate_DetailAlertScheduleID = 0
begin
	declare @ChecklistTemplate_DetailAlertScheduleID table (ChecklistTemplate_DetailAlertScheduleID int)
	insert into ChecklistTemplate_DetailAlertSchedule (
		
		ChecklistTemplate_DetailID
		, AlertDescription
		, AlertTemplateID
		, TimeFromStep
		, TimeFromStep_DatePartID
		, StartDateOrEndDate
	)
	output inserted.ChecklistTemplate_DetailAlertScheduleID into @ChecklistTemplate_DetailAlertScheduleID(ChecklistTemplate_DetailAlertScheduleID)
	select
		
		@I_vChecklistTemplate_DetailID
		,@I_vAlertDescription
		,@I_vAlertTemplateID
		,@I_vTimeFromStep
		,@I_vTimeFromStep_DatePartID
		,@I_vStartDateOrEndDate
	select top 1 @I_vChecklistTemplate_DetailAlertScheduleID = ChecklistTemplate_DetailAlertScheduleID, @iRowID = ChecklistTemplate_DetailAlertScheduleID from @ChecklistTemplate_DetailAlertScheduleID
end
else
begin
	update ChecklistTemplate_DetailAlertSchedule
	set
		
		ChecklistTemplate_DetailID = @I_vChecklistTemplate_DetailID
		,AlertDescription = @I_vAlertDescription
		,AlertTemplateID = @I_vAlertTemplateID
		,TimeFromStep = @I_vTimeFromStep
		,TimeFromStep_DatePartID = @I_vTimeFromStep_DatePartID
		,StartDateOrEndDate = @I_vStartDateOrEndDate
	where @I_vChecklistTemplate_DetailAlertScheduleID = ChecklistTemplate_DetailAlertScheduleID
	select @iRowID = @I_vChecklistTemplate_DetailAlertScheduleID
end
