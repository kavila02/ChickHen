if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Attachment_Delete' and s.name = 'dbo')
begin
	drop proc Attachment_Delete
end
go

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