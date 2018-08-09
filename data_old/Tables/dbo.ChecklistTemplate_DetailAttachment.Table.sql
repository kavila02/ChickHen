if not exists (select 1 from sys.tables where name = 'ChecklistTemplate_DetailAttachment')
begin
create table ChecklistTemplate_DetailAttachment
(
	ChecklistTemplate_DetailAttachmentID int primary key identity(1,1)
	,ChecklistTemplate_DetailID int foreign key references ChecklistTemplate_Detail(ChecklistTemplate_DetailID)
	,AttachmentID int foreign key references Attachment(AttachmentID)
	,AttachmentTypeID int foreign key references AttachmentType(AttachmentTypeID)
	,UserName nvarchar(255)
)
create nonclustered index IX_ChecklistTemplate_DetailAttachment_ChecklistTemplate_DetailID
on ChecklistTemplate_DetailAttachment(ChecklistTemplate_DetailID)
create nonclustered index IX_ChecklistTemplate_DetailAttachment_AttachmentID
on ChecklistTemplate_DetailAttachment(AttachmentID)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'ChecklistTemplate_DetailAttachment' and c.Name='AttachmentTypeID')
begin
	alter table ChecklistTemplate_DetailAttachment add AttachmentTypeID int foreign key references AttachmentType(AttachmentTypeID)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'ChecklistTemplate_DetailAttachment' and c.Name='UserName')
begin
	alter table ChecklistTemplate_DetailAttachment add UserName nvarchar(255)
end