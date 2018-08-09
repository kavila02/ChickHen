if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_DetailAttachment_GetList' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_DetailAttachment_GetList
end
GO

create proc ChecklistTemplate_DetailAttachment_GetList
@ChecklistTemplate_DetailID int
,@IncludeNew bit = 1
As

select
	ChecklistTemplate_DetailAttachmentID
	, fa.ChecklistTemplate_DetailID
	, fa.AttachmentID
	, a.DisplayName
	, a.FileDescription
	, convert(varchar,fa.ChecklistTemplate_DetailAttachmentID) + '&p=' + convert(varchar,fa.ChecklistTemplate_DetailID) as LinkValue
	, IsNull(at.AttachmentType,'') As AttachmentType
	, convert(bit,null) as upload
	, replace(substring(a.Path,2,LEN(a.Path)),'\','/') As PathLink
from ChecklistTemplate_DetailAttachment fa
	inner join Attachment a on fa.AttachmentID = a.AttachmentID
	left outer join AttachmentType at on fa.AttachmentTypeID = at.AttachmentTypeID
where @ChecklistTemplate_DetailID = ChecklistTemplate_DetailID
union all
select
	ChecklistTemplate_DetailAttachmentID = convert(int,0)
	, ChecklistTemplate_DetailID = @ChecklistTemplate_DetailID
	, AttachmentID = convert(int,0)
	, DisplayName=''
	, FileDescription=''
	, LinkValue = '0&p=' + convert(varchar,@ChecklistTemplate_DetailID)
	, AttachmentType = ''
	, upload = convert(bit,1)
	, PathLink = null
where @IncludeNew = 1
