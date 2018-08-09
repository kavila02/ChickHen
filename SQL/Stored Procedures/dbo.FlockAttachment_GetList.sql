
create proc [dbo].[FlockAttachment_GetList]
@FlockID int
,@IncludeNew bit = 1
As

select
	FlockAttachmentID
	, fa.FlockID
	, fa.AttachmentID
	, a.DisplayName
	, a.FileDescription
	, convert(varchar,fa.FlockAttachmentID) + '&p=' + convert(varchar,fa.FlockID) as LinkValue
	, IsNull(at.AttachmentType,'') As AttachmentType
	, convert(bit,null) as upload
	, replace(substring(a.Path,2,LEN(a.Path)),'\','/') As PathLink
from FlockAttachment fa
	inner join Attachment a on fa.AttachmentID = a.AttachmentID
	left outer join AttachmentType at on fa.AttachmentTypeID = at.AttachmentTypeID
where @FlockID = FlockID
union all
select
	FlockAttachmentID = convert(int,0)
	, FlockID = @FlockID
	, AttachmentID = convert(int,0)
	, DisplayName=''
	, FileDescription=''
	, LinkValue = '0&p=' + convert(varchar,@FlockID)
	, AttachmentType = ''
	, convert(bit,1) as upload
	, NULL As PathLink
where @IncludeNew = 1