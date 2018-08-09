if not exists (select 1 from sys.tables where name = 'FlockAttachment')
begin
create table FlockAttachment
(
	FlockAttachmentID int primary key identity(1,1)
	,FlockID int foreign key references Flock(FlockID)
	,AttachmentID int foreign key references Attachment(AttachmentID)
	,AttachmentTypeID int foreign key references AttachmentType(AttachmentTypeID)
	,UserName nvarchar(255)
)
create nonclustered index IX_FlockAttachment_FlockID
on FlockAttachment(FlockID)
create nonclustered index IX_FlockAttachment_AttachmentID
on FlockAttachment(AttachmentID)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockAttachment' and c.Name='AttachmentTypeID')
begin
	alter table FlockAttachment add AttachmentTypeID int foreign key references AttachmentType(AttachmentTypeID)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockAttachment' and c.Name='UserName')
begin
	alter table FlockAttachment add UserName nvarchar(255)
end