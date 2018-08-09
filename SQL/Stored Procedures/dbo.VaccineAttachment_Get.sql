
CREATE proc [dbo].[VaccineAttachment_Get]
@VaccineAttachmentID int = 0
,@VaccineID int
,@UserName nvarchar(255) = ''
As

if @VaccineAttachmentID > 0
begin
	select
		a.AttachmentID
		, FileDescription
		, Path
		, DisplayName
		, DriveName
		, FileSize
		, va.VaccineAttachmentID
		, va.VaccineID
		, va.AttachmentTypeID
		, va.UserName
		, convert(bit,0) as Upload
		, convert(bit,0) as ShowFileTree
		, REVERSE(SUBSTRING(REVERSE(Path),CHARINDEX('\',REVERSE(Path)),LEN(Path))) as Folder
		, DisplayName as FileName
		, convert(smallint,2) as fileType
		, convert(bit,0) as foldersOnly
		, replace(a.Path,atts.BaseAttachmentDirectory,'') as Location
		, atts.BaseAttachmentDirectory
		, '' As DefaultFolder
		, IsNull(AttachmentType,'') as AttachmentType
		, '' As TreeLabel
	from VaccineAttachment va
	inner join Attachment a on va.AttachmentID = a.AttachmentID
	inner join Vaccine v on va.VaccineID = v.VaccineID
	cross join AttachmentSettings atts
	left outer join AttachmentType at on va.AttachmentTypeID = at.AttachmentTypeID
	where @VaccineAttachmentID = va.VaccineAttachmentID
end
else
begin
	select
		AttachmentID = convert(int,0)
		, FileDescription = convert(nvarchar(255),'')
		, '' As Path
		, VaccineAttachmentID = @VaccineAttachmentID
		, VaccineID = @VaccineID
		, AttachmentTypeID = convert(int,null)
		, UserName = @UserName
		, convert(bit,1) as Upload
		, convert(bit,1) as ShowFileTree
		, '' as Folder
		, '' as FileName
		, convert(smallint,2) as fileType
		, convert(bit,0) as foldersOnly
		, '' as Location
		, BaseAttachmentDirectory
		, rtrim(BaseAttachmentDirectory) + '\Vaccine\' 
			+ IsNull(dbo.FolderNameClean(rtrim(v.VaccineName)) + '\','')
			As DefaultFolder
		, '' As AttachmentType
		, '' As TreeLabel
	from AttachmentSettings atts
	cross join Vaccine v
	where IsNull(@VaccineAttachmentID,0) = 0
	and v.VaccineID = @VaccineID
end