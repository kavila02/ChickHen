
create proc Attachment_Delete
	@AttachmentID int = 0 --leaving as default will delete all invalid references
AS

delete from Attachment
where @AttachmentID in (0,AttachmentID)
and AttachmentID not in
(
		  select AttachmentID from FlockAttachment
union all select AttachmentID from FlockChecklistAttachment --currently not used
union all select AttachmentID from FlockChecklist_DetailAttachment
union all select AttachmentID from ChecklistTemplateAttachment --currently not used
union all select AttachmentID from ChecklistTemplate_DetailAttachment
union all select AttachmentID from VaccineAttachment
)