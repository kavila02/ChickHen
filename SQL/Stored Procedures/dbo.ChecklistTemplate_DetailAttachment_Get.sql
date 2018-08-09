

CREATE proc [dbo].[ChecklistTemplate_DetailAttachment_Get]
@ChecklistTemplate_DetailAttachmentID int = 0
,@ChecklistTemplate_DetailID int
,@UserName nvarchar(255) = ''
As

if @ChecklistTemplate_DetailAttachmentID > 0
begin
	select
		a.AttachmentID
		, FileDescription
		, Path
		, DisplayName
		, DriveName
		, FileSize
		, da.ChecklistTemplate_DetailAttachmentID
		, da.ChecklistTemplate_DetailID
		, da.AttachmentTypeID
		, da.UserName
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
	from ChecklistTemplate_DetailAttachment da
	cross join AttachmentSettings atts
	inner join ChecklistTemplate_Detail d on da.ChecklistTemplate_DetailID = d.ChecklistTemplate_DetailID
	inner join ChecklistTemplate ct on d.ChecklistTemplateID = ct.ChecklistTemplateID
	inner join Attachment a on da.AttachmentID = a.AttachmentID
	left outer join AttachmentType at on da.AttachmentTypeID = at.AttachmentTypeID
	where @ChecklistTemplate_DetailAttachmentID = da.ChecklistTemplate_DetailAttachmentID
end
else
begin
	select
		AttachmentID = convert(int,0)
		, FileDescription = convert(nvarchar(255),'')

		, ChecklistTemplate_DetailAttachmentID = @ChecklistTemplate_DetailAttachmentID
		, ChecklistTemplate_DetailID = @ChecklistTemplate_DetailID
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
		, rtrim(BaseAttachmentDirectory) + '\' 
			+ 'Template Attachments\'
			+ IsNull(dbo.FolderNameClean(ct.TemplateName) + '\' ,'')
			+ IsNull(dbo.FolderNameClean(d.StepName) + '\' ,'')
			As DefaultFolder
		, '' As AttachmentType
		, '' As TreeLabel
	from AttachmentSettings atts
	cross join ChecklistTemplate_Detail d
	inner join ChecklistTemplate ct on d.ChecklistTemplateID = ct.ChecklistTemplateID
	where IsNull(@ChecklistTemplate_DetailAttachmentID,0) = 0
	and d.ChecklistTemplate_DetailID = @ChecklistTemplate_DetailID
end