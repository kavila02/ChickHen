if not exists (select 1 from sys.tables where name = 'FlockChecklist_DetailAttachment')
begin
create table FlockChecklist_DetailAttachment
(
	FlockChecklist_DetailAttachmentID int primary key identity(1,1)
	,FlockChecklist_DetailID int foreign key references FlockChecklist_Detail(FlockChecklist_DetailID)
	,AttachmentID int foreign key references Attachment(AttachmentID)
	,AttachmentTypeID int foreign key references AttachmentType(AttachmentTypeID)
	,UserName nvarchar(255)
)
create nonclustered index IX_FlockChecklist_DetailAttachment_FlockChecklist_DetailID
on FlockChecklist_DetailAttachment(FlockChecklist_DetailID)
create nonclustered index IX_FlockChecklist_DetailAttachment_AttachmentID
on FlockChecklist_DetailAttachment(AttachmentID)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockChecklist_DetailAttachment' and c.Name='AttachmentTypeID')
begin
	alter table FlockChecklist_DetailAttachment add AttachmentTypeID int foreign key references AttachmentType(AttachmentTypeID)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockChecklist_DetailAttachment' and c.Name='UserName')
begin
	alter table FlockChecklist_DetailAttachment add UserName nvarchar(255)
end