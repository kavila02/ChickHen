if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockAttachment_Get' and s.name = 'dbo')
begin
	drop proc FlockAttachment_Get
end
GO

create proc [dbo].[FlockAttachment_Get]
@FlockAttachmentID int = 0
,@FlockID int
,@UserName nvarchar(255) = ''
As

if @FlockAttachmentID > 0
begin
	select
		a.AttachmentID
		, FileDescription
		, Path
		, DisplayName
		, DriveName
		, FileSize
		, fa.FlockAttachmentID
		, fa.FlockID
		, fa.AttachmentTypeID
		, fa.UserName
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
	from FlockAttachment fa
	inner join Attachment a on fa.AttachmentID = a.AttachmentID
	inner join Flock f on fa.FlockID = f.FlockID
	cross join AttachmentSettings atts
	left outer join AttachmentType at on fa.AttachmentTypeID = at.AttachmentTypeID
	where @FlockAttachmentID = fa.FlockAttachmentID
end
else
begin
	select
		AttachmentID = convert(int,0)
		, FileDescription = convert(nvarchar(255),'')
		, '' As Path
		, FlockAttachmentID = @FlockAttachmentID
		, FlockID = @FlockID
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
		, rtrim(BaseAttachmentDirectory) + '\FDA Records\'
			+ rtrim(l.FolderName) + '\'
			+ 'FDA ' + l.LocationAbbreviation + ' House ' + replace(rtrim(lh.LayerHouseName),'-',' ') + '\'
			+ 'FDA Flock ' + dbo.csiStripNonNumericFromString(FlockName) + ' ' + l.LocationAbbreviation + ' ' + replace(rtrim(lh.LayerHouseName),'-',' ') + '\'
			as DefaultFolder
		--, rtrim(BaseAttachmentDirectory) + '\' 
		--	+ IsNull(dbo.FolderNameClean(rtrim(l.Location)) + '\','')
		--	+ IsNull(dbo.FolderNameClean(rtrim(lh.LayerHouseName)) + '\','')
		--	+ IsNull(dbo.FolderNameClean(rtrim(f.FlockName)) + '\','')
		--	As DefaultFolder
		, '' As AttachmentType
		, '' As TreeLabel
	from AttachmentSettings atts
	cross join Flock f
	left outer join LayerHouse lh on f.LayerHouseID = lh.LayerHouseID
	left outer join Location l on lh.LocationID = l.LocationID
	where IsNull(@FlockAttachmentID,0) = 0
	and f.FlockID = @FlockID
end