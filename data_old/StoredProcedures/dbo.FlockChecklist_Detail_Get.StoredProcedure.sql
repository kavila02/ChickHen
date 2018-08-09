if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockChecklist_Detail_Get' and s.name = 'dbo')
begin
	drop proc FlockChecklist_Detail_Get
end
GO
create proc FlockChecklist_Detail_Get
@FlockChecklist_DetailID int
,@Checklist_DetailTypeID int = null
,@FlockChecklistID int
,@IncludeNew bit = 0
As

declare @AttachmentsHtml nvarchar(max) = ''
select  @AttachmentsHtml = @AttachmentsHtml + 
a.FileDescription + ': <a name="Attachments" id="Attachments" href="' + replace(substring(a.Path,2,LEN(a.Path)),'\','/') + '" title="' + a.DisplayName + '" style="padding-right:25px;">
    <i id="AttachmentsIcon" class="center material-icons ng-binging ng-scope">insert_drive_file</i>
</a>'
from FlockChecklist_Detail fd
	inner join ChecklistTemplate_DetailAttachment da on fd.ChecklistTemplate_DetailID = da.ChecklistTemplate_DetailID
	inner join Attachment a on da.AttachmentID = a.AttachmentID
where fd.FlockChecklist_DetailID = @FlockChecklist_DetailID


declare @vaccines nvarchar(255) = ''
 select  @vaccines = @vaccines + case when @vaccines = '' then '' else ', ' end + rtrim(v.VaccineName)
 from FlockChecklist_Detail_Vaccine fv
		inner join Vaccine v on v.VaccineID = fv.VaccineID
where @FlockChecklist_DetailID = FlockChecklist_DetailID

select
	d.FlockChecklist_DetailID
	, d.FlockChecklistID
	, d.StepName
	, d.StepOrder
	, d.ActionDescription

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

	, d.OriginatorID
	, d.DetailedNotes
	, d.Detail_StatusID
	, convert(bit,0) as ShowCalculationDetails
	, convert(bit,0) as ShowCalculationDetails_EndDate
	, d.DateOfAction
	, d.DateOfAction_EndDate
	, d.CompletedByID
	, d.CompletedDate
	, @AttachmentsHtml As AttachmentsHtml
	, f.FlockName
	, f.FlockID
	, Checklist_DetailTypeID
	, case when @vaccines = '' then '{Add Vaccines}' else @vaccines end as Vaccines
from FlockChecklist_Detail d
	inner join FlockChecklist fc on d.FlockChecklistID = fc.FlockChecklistID
	inner join Flock f on fc.FlockID = f.FlockID
where FlockChecklist_DetailID = @FlockChecklist_DetailID
union all
select
	FlockChecklist_DetailID = convert(int,0)
	, FlockChecklistID = @FlockChecklistID
	, StepName = convert(nvarchar(255),'')
	, StepOrder = convert(int,IsNull((Select MAX(StepOrder) + 1 from FlockChecklist_Detail where FlockChecklistID = @FlockChecklistID),1))
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
	, Detail_StatusID = convert(int,null)
	, ShowCalculationDetails = convert(bit,0)
	, ShowCalculationDetails_EndDate = convert(bit,0)
	, DateOfAction = convert(date,null)
	, DateOfAction_EndDate = convert(date,null)
	, CompletedByID = convert(int,null)
	, CompletedDate = convert(date,null)
	, @AttachmentsHtml As AttachmentsHtml
	, (select f.FlockName from FlockChecklist fc inner join Flock f on fc.FlockID = f.FlockID where fc.FlockChecklistID = @FlockChecklistID) As Flockname
	, (select FlockID from FlockChecklist where FlockChecklistID = @FlockChecklistID) as FlockID
	, @Checklist_DetailTypeID as Checklist_DetailTypeID
	, case when @vaccines = '' then '{Add Vaccines}' else @vaccines end as Vaccines
where @IncludeNew = 1
Order by StepOrder