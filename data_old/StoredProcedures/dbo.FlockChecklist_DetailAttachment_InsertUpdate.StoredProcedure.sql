if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockChecklist_DetailAttachment_InsertUpdate' and s.name = 'dbo')
begin
	drop proc FlockChecklist_DetailAttachment_InsertUpdate
end
GO

Create Proc FlockChecklist_DetailAttachment_InsertUpdate
@I_vAttachmentID int = 0
,@I_vFlockChecklist_DetailAttachmentID int
,@I_vFlockChecklist_DetailID int
,@I_vFileDescription varchar(255) = ''
,@I_vAttachmentTypeID int = null
,@I_vUserName nvarchar(255) = ''
,@I_vPath varchar(255)
,@I_vDisplayName varchar(8000)
,@I_vDriveName varchar(255) = ''
,@I_vFileSize int = 0
, @O_iErrorState int=0 output 
, @oErrString varchar(255)='' output
, @iRowID int=0 output
AS

declare @attachmentID table (AttachmentID int)

if @I_vAttachmentID = 0
begin
	insert into Attachment (FileDescription, Path, DisplayName, DriveName, FileSize)
	output inserted.AttachmentID into @attachmentID
	select
		@I_vFileDescription
		,@I_vPath
		,@I_vDisplayName
		,@I_vDriveName
		,@I_vFileSize

	select @I_vAttachmentID = AttachmentID, @iRowID = AttachmentID from @attachmentID
end
else
begin
	update Attachment
	set
		FileDescription = @I_vFileDescription
		, Path = @I_vPath
		, DisplayName = @I_vDisplayName
		, DriveName = @I_vDriveName
		, FileSize = @I_vFileSize
	where
		AttachmentID = @I_vAttachmentID

	select @iRowID = @I_vAttachmentID
end

if @I_vFlockChecklist_DetailAttachmentID = 0
begin
	insert into FlockChecklist_DetailAttachment (
		FlockChecklist_DetailID
		, AttachmentID
		, AttachmentTypeID
		, UserName
	)
	select
		@I_vFlockChecklist_DetailID
		,@I_vAttachmentID
		,@I_vAttachmentTypeID
		,@I_vUserName
end
else
begin
	update FlockChecklist_DetailAttachment
	set
		
		FlockChecklist_DetailID = @I_vFlockChecklist_DetailID
		,AttachmentID = @I_vAttachmentID
		,AttachmentTypeID = @I_vAttachmentTypeID
		,UserName = @I_vUserName
	where @I_vFlockChecklist_DetailAttachmentID = FlockChecklist_DetailAttachmentID
end