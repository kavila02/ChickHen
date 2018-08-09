if not exists (select 1 from sys.tables where name = 'ChecklistTemplateContact')
begin
create table ChecklistTemplateContact
(
	ChecklistTemplateContactID int primary key identity(1,1)
	,ChecklistTemplateID int foreign key references ChecklistTemplate(ChecklistTemplateID)
	,ContactRoleID int foreign key references ContactRole(ContactRoleID)
	,ContactID int foreign key references Contact(ContactID)
)
end
