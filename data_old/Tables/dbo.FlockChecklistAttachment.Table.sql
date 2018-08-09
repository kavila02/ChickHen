if not exists (select 1 from sys.tables where name = 'FlockChecklistAttachment')
begin
create table FlockChecklistAttachment
(
	FlockChecklistAttachmentID int primary key identity(1,1)
	,FlockChecklistID int foreign key references FlockChecklist(FlockChecklistID)
	,AttachmentID int foreign key references Attachment(AttachmentID)
)
create nonclustered index IX_FlockChecklistAttachment_FlockChecklistID
on FlockChecklistAttachment(FlockChecklistID)
create nonclustered index IX_FlockChecklistAttachment_AttachmentID
on FlockChecklistAttachment(AttachmentID)
end