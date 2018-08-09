if not exists (select 1 from sys.tables where name = 'Contact')
begin
create table Contact
(
	ContactID int primary key identity(1,1)
	,ContactName nvarchar(255)
	,PrimaryEmailAddress nvarchar(255)
	,SecondaryEmailAddress nvarchar(255)
	,PhoneNumber nvarchar(20)
	,Active bit
)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Contact' and c.name = 'Active')
begin
	alter table Contact add Active bit
end