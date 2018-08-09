if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockChecklist_DetailAttachment_Delete' and s.name = 'dbo')
begin
	drop proc FlockChecklist_DetailAttachment_Delete
end
GO
create proc FlockChecklist_DetailAttachment_Delete
	@I_vFlockChecklist_DetailAttachmentID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

declare @attachmentID int
select @attachmentID = AttachmentID from FlockChecklist_DetailAttachment where FlockChecklist_DetailAttachmentID = @I_vFlockChecklist_DetailAttachmentID
delete from FlockChecklist_DetailAttachment where FlockChecklist_DetailAttachmentID = @I_vFlockChecklist_DetailAttachmentID

exec Attachment_Delete @AttachmentID = @attachmentID