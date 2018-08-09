if not exists (select 1 from sys.tables where name = 'VaccineAttachment')
begin
create table VaccineAttachment
(
	VaccineAttachmentID int primary key identity(1,1)
	,VaccineID int foreign key references Vaccine(VaccineID)
	,AttachmentID int foreign key references Attachment(AttachmentID)
	,AttachmentTypeID int foreign key references AttachmentType(AttachmentTypeID)
	,UserName nvarchar(255)
)
create nonclustered index IX_VaccineAttachment_VaccineID
on VaccineAttachment(VaccineID)
create nonclustered index IX_VaccineAttachment_AttachmentID
on VaccineAttachment(AttachmentID)
end
