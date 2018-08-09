if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockAttachment_Delete' and s.name = 'dbo')
begin
	drop proc FlockAttachment_Delete
end
GO
create proc FlockAttachment_Delete
	@I_vFlockAttachmentID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

declare @attachmentID int
select @attachmentID = AttachmentID from FlockAttachment where FlockAttachmentID = @I_vFlockAttachmentID
delete from FlockAttachment where FlockAttachmentID = @I_vFlockAttachmentID

exec Attachment_Delete @AttachmentID = @attachmentID
