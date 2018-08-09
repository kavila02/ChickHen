
create proc [dbo].[FlockChecklist_DetailAttachment_GetList]
@FlockChecklist_DetailID int = null
,@FlockID int = null
,@IncludeNew bit = 1
As

select
	FlockChecklist_DetailAttachmentID
	, fa.FlockChecklist_DetailID
	, fa.AttachmentID
	, a.DisplayName
	, a.FileDescription
	, convert(varchar,fa.FlockChecklist_DetailAttachmentID) + '&p=' + convert(varchar,fa.FlockChecklist_DetailID) as LinkValue
	, IsNull(at.AttachmentType,'') As AttachmentType
	, convert(bit,null) as upload
	,fd.StepName
	,fd.StepOrder
	,fd.DateOfAction
	,fd.CompletedDate
	, replace(substring(a.Path,2,LEN(a.Path)),'\','/') As PathLink
	
from FlockChecklist_DetailAttachment fa
	inner join FlockChecklist_Detail fd on fa.FlockChecklist_DetailID = fd.FlockChecklist_DetailID
	inner join FlockChecklist fc on fd.FlockChecklistID = fc.FlockChecklistID
	inner join Attachment a on fa.AttachmentID = a.AttachmentID
	left outer join AttachmentType at on fa.AttachmentTypeID = at.AttachmentTypeID
where @FlockChecklist_DetailID = fa.FlockChecklist_DetailID
	or fc.FlockID = @FlockID
union all
select
	FlockChecklist_DetailAttachmentID = convert(int,0)
	, FlockChecklist_DetailID = @FlockChecklist_DetailID
	, AttachmentID = convert(int,0)
	, DisplayName=''
	, FileDescription=''
	, LinkValue = '0&p=' + convert(varchar,@FlockChecklist_DetailID)
	, AttachmentType = ''
	, convert(bit,1) as upload
	,fd.StepName
	,fd.StepOrder
	,fd.DateOfAction
	,fd.CompletedDate
	,PathLink = NULL
	
from FlockChecklist_Detail fd where FlockChecklist_DetailID = @FlockChecklist_DetailID
	and @IncludeNew = 1
	and @FlockChecklist_DetailID is not null
Order By StepOrder