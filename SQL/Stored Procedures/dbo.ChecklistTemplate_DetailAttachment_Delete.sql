create proc ChecklistTemplate_DetailAttachment_Delete
	@I_vChecklistTemplate_DetailAttachmentID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

declare @attachmentID int
select @attachmentID = AttachmentID from ChecklistTemplate_DetailAttachment where ChecklistTemplate_DetailAttachmentID = @I_vChecklistTemplate_DetailAttachmentID
delete from ChecklistTemplate_DetailAttachment where ChecklistTemplate_DetailAttachmentID = @I_vChecklistTemplate_DetailAttachmentID

exec Attachment_Delete @AttachmentID = @attachmentID