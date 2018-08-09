if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'VaccineAttachment_Delete' and s.name = 'dbo')
begin
	drop proc VaccineAttachment_Delete
end
GO
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
