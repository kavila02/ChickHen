if not exists (select 1 from sys.tables where name = 'AttachmentSettings')
begin
create table AttachmentSettings
(
	AttachmentSettingsID int primary key identity(1,1)
	,BaseAttachmentDirectory varchar(500)
)
end

insert into AttachmentSettings (BaseAttachmentDirectory)
select '\solution\Attachments'