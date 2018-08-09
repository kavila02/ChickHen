if not exists (select 1 from sys.tables where name = 'ChecklistTemplateAttachment')
begin
create table ChecklistTemplateAttachment
(
	ChecklistTemplateAttachmentID int primary key identity(1,1)
	,ChecklistTemplateID int foreign key references ChecklistTemplate(ChecklistTemplateID)
	,AttachmentID int foreign key references Attachment(AttachmentID)
)
create nonclustered index IX_ChecklistTemplateAttachment_ChecklistTemplateID
on ChecklistTemplateAttachment(ChecklistTemplateID)
create nonclustered index IX_FlockAttachment_AttachmentID
on ChecklistTemplateAttachment(AttachmentID)
end