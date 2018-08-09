if not exists (select 1 from sys.tables where name = 'FlockChecklistContact')
begin
create table FlockChecklistContact
(
	FlockChecklistContactID int primary key identity(1,1)
	,FlockChecklistID int foreign key references FlockChecklist(FlockChecklistID)
	,ContactRoleID int foreign key references ContactRole(ContactRoleID)
	,ContactID int foreign key references Contact(ContactID)
)
end
