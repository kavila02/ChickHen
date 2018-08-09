if not exists (select 1 from sys.tables where name = 'Hatchery')
begin
	create table Hatchery
	(
		HatcheryID int primary key identity(1,1)
		,Hatchery nvarchar(255)
		,SortOrder int
		,IsActive bit
	)
end