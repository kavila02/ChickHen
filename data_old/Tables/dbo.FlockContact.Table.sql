if not exists (select 1 from sys.tables where name = 'FlockContact')
begin
create table FlockContact
(
	FlockContactID int primary key identity(1,1)
	,FlockID int foreign key references Flock(FlockID)
	,ContactRoleID int foreign key references ContactRole(ContactRoleID)
	,ContactID int foreign key references Contact(ContactID)
)
end

--dear future me:
--for example, the flock will have a list at the bottom of the page
--Role: Production Manager		Contact: Jodie Macariole
--
--This allows the user to define the various people associated with the flock for email alert purposes
--so the email alert could say "email the flock Production Manager"