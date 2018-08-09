﻿
Create Proc VaccineAttachment_InsertUpdate
@I_vAttachmentID int = 0
,@I_vVaccineAttachmentID int
,@I_vVaccineID int
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

if @I_vVaccineAttachmentID = 0
begin
	insert into VaccineAttachment (
		VaccineID
		, AttachmentID
		, AttachmentTypeID
		, UserName
	)
	select
		@I_vVaccineID
		,@I_vAttachmentID
		,@I_vAttachmentTypeID
		,@I_vUserName
end
else
begin
	update VaccineAttachment
	set
		
		VaccineID = @I_vVaccineID
		,AttachmentID = @I_vAttachmentID
		,AttachmentTypeID = @I_vAttachmentTypeID
		,UserName = @I_vUserName
	where @I_vVaccineAttachmentID = VaccineAttachmentID
end