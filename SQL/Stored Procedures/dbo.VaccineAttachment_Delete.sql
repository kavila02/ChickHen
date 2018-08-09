create proc VaccineAttachment_Delete
	@I_vVaccineAttachmentID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

declare @attachmentID int
select @attachmentID = AttachmentID from VaccineAttachment where VaccineAttachmentID = @I_vVaccineAttachmentID
delete from VaccineAttachment where VaccineAttachmentID = @I_vVaccineAttachmentID

exec Attachment_Delete @AttachmentID = @attachmentID