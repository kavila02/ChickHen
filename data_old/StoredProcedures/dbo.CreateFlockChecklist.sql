create proc CreateFlockChecklist
	 @FlockID int
	,@ChecklistTemplateID int
AS


--check if there's already a checklist. if there is, add to it
declare @FlockChecklistID_table table (FlockChecklistID int)
declare @FlockChecklistID int

if not exists (select 1 from FlockChecklist where FlockID = @FlockID)
begin
	insert into FlockChecklist (FlockChecklistName, ChecklistTemplateID, FlockID)
	output inserted.FlockChecklistID into @FlockChecklistID_table(FlockChecklistID)
	Select TemplateName, @ChecklistTemplateID, @FlockID
		from ChecklistTemplate
		where ChecklistTemplateID = @ChecklistTemplateID
	Select top 1 @FlockChecklistID = FlockChecklistID from @FlockChecklistID_table
end
else
begin
	Select top 1 @FlockChecklistID = FlockChecklistID from FlockChecklist where FlockID = @FlockID
end

declare @StepOrder table (Checklist_DetailTypeID int, MaxStepOrder int)
insert into @StepOrder select Checklist_DetailTypeID, Max(StepOrder)
from FlockChecklist_Detail
where FlockChecklistID = @FlockChecklistID
group by Checklist_DetailTypeID

--insert all the steps from the checklist
insert into FlockChecklist_Detail (FlockChecklistID, StepName, StepOrder, ActionDescription
		, DateOfAction, StepOrFieldCalculation, DateOfAction_TimeFromStep, TimeFromStep_DatePartID, DateOfAction_FlockChecklist_DetailID, DateOfAction_TimeFromField, TimeFromField_DatePartID, DateOfAction_FieldReferenceID
		, DateOfAction_EndDate, StepOrFieldCalculation_EndDate, DateOfAction_TimeFromStep_EndDate, TimeFromStep_DatePartID_EndDate, DateOfAction_FlockChecklist_DetailID_EndDate, DateOfAction_TimeFromField_EndDate, TimeFromField_DatePartID_EndDate, DateOfAction_FieldReferenceID_EndDate
		, OriginatorID, DetailedNotes, CompletedByID, CompletedDate, Detail_StatusID, ChecklistTemplate_DetailID, Checklist_DetailTypeID)
select @FlockChecklistID
	,StepName
	,IsNull(s.MaxStepOrder,0) + StepOrder
	,ActionDescription

	,null --DateOfAction
	,StepOrFieldCalculation
	,DateOfAction_TimeFromStep
	,TimeFromStep_DatePartID
	,null --DateOfAction_FlockChecklist_DetailID
	,DateOfAction_TimeFromField
	,TimeFromField_DatePartID
	,DateOfAction_FieldReferenceID

	,null --DateOfAction
	,StepOrFieldCalculation_EndDate
	,DateOfAction_TimeFromStep_EndDate
	,TimeFromStep_DatePartID_EndDate
	,null --DateOfAction_FlockChecklist_DetailID
	,DateOfAction_TimeFromField_EndDate
	,TimeFromField_DatePartID_EndDate
	,DateOfAction_FieldReferenceID_EndDate

	,OriginatorID
	,DetailedNotes
	,null --CompletedByID
	,null --CompletedDate
	,DefaultDetail_StatusID
	,ChecklistTemplate_DetailID
	,d.Checklist_DetailTypeID
From ChecklistTemplate_Detail d
left outer join @StepOrder s on d.Checklist_DetailTypeID = s.Checklist_DetailTypeID
where ChecklistTemplateID = @ChecklistTemplateID

update d
set d.DateOfAction_FlockChecklist_DetailID = d2.FlockChecklist_DetailID
from FlockChecklist_Detail d
	inner join ChecklistTemplate_Detail td on td.ChecklistTemplate_DetailID = d.ChecklistTemplate_DetailID --original template
	left outer join FlockChecklist_Detail d2 on td.DateOfAction_FlockChecklist_DetailID = d2.ChecklistTemplate_DetailID --original template id = original template step reference
where d.FlockChecklistID = @FlockChecklistID

--Add the alerts and the recipients.
insert into FlockChecklist_DetailAlertSchedule(FlockChecklist_DetailID, AlertDescription, AlertTemplateID, TimeFromStep, TimeFromStep_DatePartID, AlertSent, ChecklistTemplate_DetailAlertScheduleID, StartDateOrEndDate)
select fd.FlockChecklist_DetailID
	,a.AlertDescription 
	,a.AlertTemplateID 
	,a.TimeFromStep 
	,a.TimeFromStep_DatePartID 
	,0 --AlertSent 
	,ChecklistTemplate_DetailAlertScheduleID
	,StartDateOrEndDate
from ChecklistTemplate_DetailAlertSchedule a
	inner join ChecklistTemplate_Detail d on a.ChecklistTemplate_DetailID = d.ChecklistTemplate_DetailID
	inner join FlockChecklist_Detail fd on d.ChecklistTemplate_DetailID = fd.ChecklistTemplate_DetailID
	where fd.FlockChecklistID = @FlockChecklistID

insert into FlockChecklist_DetailAlertSchedule_Recipients (FlockChecklist_DetailAlertScheduleID, RecipientType, ContactRoleID, ContactID)
select
	fa.FlockChecklist_DetailAlertScheduleID
	,tr.RecipientType
	,tr.ContactRoleID
	,tr.ContactID
from ChecklistTemplate_DetailAlertSchedule_Recipients tr
	--inner join ChecklistTemplate_DetailAlertSchedule ta on tr.ChecklistTemplate_DetailAlertScheduleID = ta.ChecklistTemplate_DetailAlertScheduleID
	inner join FlockChecklist_DetailAlertSchedule fa on fa.ChecklistTemplate_DetailAlertScheduleID = tr.ChecklistTemplate_DetailAlertScheduleID
	inner join FlockChecklist_Detail fd on fa.FlockChecklist_DetailID = fd.FlockChecklist_DetailID
	where fd.FlockChecklistID = @FlockChecklistID

--insert vaccines into flockchecklist
insert into FlockChecklist_Detail_Vaccine (FlockChecklist_DetailID, VaccineID)
select fd.FlockChecklist_DetailID
		,dv.VaccineID
from ChecklistTemplate_Detail_Vaccine dv
	inner join ChecklistTemplate_Detail d on d.ChecklistTemplate_DetailID = dv.ChecklistTemplate_DetailID
	inner join FlockChecklist_Detail fd on d.ChecklistTemplate_DetailID = fd.ChecklistTemplate_DetailID
	where fd.FlockChecklistID = @FlockChecklistID

exec CalculateDateOfAction_FlockChecklist @FlockChecklistID = @FlockChecklistID

--And insert those vaccines into the flock with a status of scheduled
insert into FlockVaccine (FlockID, VaccineID, VaccineStatusID, FlockVaccineNotes, ScheduledDate, CompletedDate)
select
	fc.FlockID
	,dv.VaccineID
	,(select top 1 VaccineStatusID from VaccineStatus where VaccineStatus like '%scheduled%')
	,d.ActionDescription
	,d.DateOfAction
	,NULL
from FlockChecklist_Detail_Vaccine dv
	inner join FlockChecklist_Detail d on dv.FlockChecklist_DetailID = d.FlockChecklist_DetailID
	inner join FlockChecklist fc on d.FlockChecklistID = fc.FlockChecklistID
	--where not already exists that particular vaccine scheduled for that given day
	left outer join FlockVaccine fv on fv.VaccineID = dv.VaccineID and d.DateOfAction = fv.ScheduledDate and fv.FlockID = fc.FlockID
where fc.FlockChecklistID = @FlockChecklistID
and fv.FlockVaccineID is null


select @FlockChecklistID as ID,'forward' As referenceType