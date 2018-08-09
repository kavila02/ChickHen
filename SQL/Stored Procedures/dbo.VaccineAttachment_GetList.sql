
create proc VaccineAttachment_GetList
@VaccineID int
,@IncludeNew bit = 1
As

select
	VaccineAttachmentID
	, va.VaccineID
	, va.AttachmentID
	, a.DisplayName
	, a.FileDescription
	, convert(varchar,va.VaccineAttachmentID) + '&p=' + convert(varchar,va.VaccineID) as LinkValue
	, IsNull(at.AttachmentType,'') As AttachmentType
	, convert(bit,null) as upload
	, replace(substring(a.Path,2,LEN(a.Path)),'\','/') As PathLink
	, 'Attachments for ' + rtrim(v.VaccineName) as vaccineHeader
from VaccineAttachment va
	inner join Attachment a on va.AttachmentID = a.AttachmentID
	left outer join AttachmentType at on va.AttachmentTypeID = at.AttachmentTypeID
	inner join Vaccine v on va.VaccineID = v.VaccineID
where @VaccineID = va.VaccineID
union all
select
	VaccineAttachmentID = convert(int,0)
	, VaccineID = @VaccineID
	, AttachmentID = convert(int,0)
	, DisplayName=''
	, FileDescription=''
	, LinkValue = '0&p=' + convert(varchar,@VaccineID)
	, AttachmentType = ''
	, convert(bit,1) as upload
	, NULL As PathLink
	, 'Attachments for ' + (select rtrim(VaccineName) from Vaccine where VaccineID = @VaccineID)
where @IncludeNew = 1