if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_DetailAttachment_Delete' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_DetailAttachment_Delete
end
GO
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