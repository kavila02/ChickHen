if not exists (Select 1 from sys.tables t inner join sys.schemas s on t.schema_id = s.Schema_id where s.name = 'dbo' and t.name = 'UserToLocation')
begin
	create table UserToLocation
	(
		UserToLocationID int primary key identity(1,1)
		,UserTableID int foreign key references csb.UserTable(UserTableID)
		,LocationID int foreign key references Location(LocationID)
	)
end