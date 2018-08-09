if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockChecklist_DetailAttachment_Get' and s.name = 'dbo')
begin
	drop proc FlockChecklist_DetailAttachment_Get
end
GO

create proc FlockChecklist_DetailAttachment_Get
@FlockChecklist_DetailAttachmentID int = 0
,@FlockChecklist_DetailID int
,@UserName nvarchar(255) = ''
As

if @FlockChecklist_DetailAttachmentID > 0
begin
	select
		a.AttachmentID
		, FileDescription
		, Path
		, DisplayName
		, DriveName
		, FileSize
		, da.FlockChecklist_DetailAttachmentID
		, da.FlockChecklist_DetailID
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
	from FlockChecklist_DetailAttachment da
	cross join AttachmentSettings atts
	inner join FlockChecklist_Detail d on da.FlockChecklist_DetailID = d.FlockChecklist_DetailID
	inner join FlockChecklist fc on d.FlockChecklistID = fc.FlockChecklistID
	inner join Flock f on fc.FlockID = f.FlockID
	inner join Attachment a on da.AttachmentID = a.AttachmentID
	left outer join AttachmentType at on da.AttachmentTypeID = at.AttachmentTypeID
	where @FlockChecklist_DetailAttachmentID = da.FlockChecklist_DetailAttachmentID
end
else
begin
	select
		AttachmentID = convert(int,0)
		, FileDescription = convert(nvarchar(255),'')

		, FlockChecklist_DetailAttachmentID = @FlockChecklist_DetailAttachmentID
		, FlockChecklist_DetailID = @FlockChecklist_DetailID
		, AttachmentTypeID = convert(int,null)
		, UserName = @UserName
		, convert(bit,1) as Upload
		, convert(bit,1) as ShowFileTree
		, '' as Folder
		, '' as FileName
		, convert(smallint,0) as fileType
		, convert(bit,0) as foldersOnly
		, '' as Location
		, BaseAttachmentDirectory
		, rtrim(BaseAttachmentDirectory) + '\' 
			+ IsNull(dbo.FolderNameClean(rtrim(l.Location)) + '\','')
			+ IsNull(dbo.FolderNameClean(rtrim(lh.LayerHouseName)) + '\','')
			+ IsNull(dbo.FolderNameClean(rtrim(f.FlockName)) + '\','')
			As DefaultFolder
		, '' As AttachmentType
		, '' As TreeLabel
	from AttachmentSettings atts
	cross join FlockChecklist_Detail d
	inner join FlockChecklist fc on d.FlockChecklistID = fc.FlockChecklistID
	inner join Flock f on fc.FlockID = f.FlockID
	left outer join LayerHouse lh on f.LayerHouseID = lh.LayerHouseID
	left outer join Location l on lh.LocationID = l.LocationID
	where IsNull(@FlockChecklist_DetailAttachmentID,0) = 0
	and d.FlockChecklist_DetailID =@FlockChecklist_DetailID
end