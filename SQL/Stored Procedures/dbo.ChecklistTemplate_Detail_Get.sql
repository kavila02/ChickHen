CREATE proc [dbo].[ChecklistTemplate_Detail_Get]
@ChecklistTemplate_DetailID int
,@ChecklistTemplateID int
,@ChecklistDetail_TypeID int = null
,@IncludeNew bit = 1
As

declare @vaccines nvarchar(255) = ''
 select  @vaccines = @vaccines + case when @vaccines = '' then '' else ', ' end + rtrim(v.VaccineName)
 from ChecklistTemplate_Detail_Vaccine dv
		inner join Vaccine v on v.VaccineID = dv.VaccineID
where @ChecklistTemplate_DetailID = ChecklistTemplate_DetailID

select
	ChecklistTemplate_DetailID
	, ChecklistTemplateID
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
	, Checklist_DetailTypeID
	, case when @vaccines = '' then '{Add Vaccines}' else @vaccines end as Vaccines
from ChecklistTemplate_Detail
where ChecklistTemplate_DetailID = @ChecklistTemplate_DetailID
union all
select
	ChecklistTemplate_DetailID = convert(int,0)
	, ChecklistTemplateID = @ChecklistTemplateID
	, StepName = convert(nvarchar(255),'')
	, StepOrder = convert(int,IsNull((Select MAX(StepOrder) + 1 from ChecklistTemplate_Detail where ChecklistTemplateID = @ChecklistTemplateID),1))
	, ActionDescription = convert(nvarchar(500),'')

	, StepOrFieldCalculation = convert(smallint,null)
	, DateOfAction_TimeFromStep = convert(int,null)
	, TimeFromStep_DatePartID = convert(varchar(4),null)
	, DateOfAction_FlockChecklist_DetailID = convert(int,null)
	, DateOfAction_TimeFromField = convert(int,null)
	, TimeFromField_DatePartID = convert(varchar(4),null)
	, DateOfAction_FieldReferenceID = convert(int,null)
	
	, StepOrFieldCalculation_EndDate = convert(smallint,null)
	, DateOfAction_TimeFromStep_EndDate = convert(int,null)
	, TimeFromStep_DatePartID_EndDate = convert(varchar(4),null)
	, DateOfAction_FlockChecklist_DetailID_EndDate = convert(int,null)
	, DateOfAction_TimeFromField_EndDate = convert(int,null)
	, TimeFromField_DatePartID_EndDate = convert(varchar(4),null)
	, DateOfAction_FieldReferenceID_EndDate = convert(int,null)

	, OriginatorID = convert(int,null)
	, DetailedNotes = convert(nvarchar(4000),'')
	, DefaultDetail_StatusID = convert(int,1)
	, Checklist_DetailTypeID = @ChecklistDetail_TypeID
	, case when @vaccines = '' then '{Add Vaccines}' else @vaccines end as Vaccines
where @IncludeNew = 1
Order by StepOrder