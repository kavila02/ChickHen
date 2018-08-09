if not exists (select 1 from sys.tables where name = 'ProductBreed')
begin
create table ProductBreed
(
	ProductBreedID int primary key identity(1,1)
	,ProductBreed nvarchar(255)
	,NumberOfWeeks numeric(19,2)
	,WeeksHatchToHouse numeric(19,2)
	,SortOrder int
	,IsActive bit
)
end

If not exists (select 1 from ProductBreed)
	insert into ProductBreed (ProductBreed, SortOrder, IsActive)
	select 'LSL',1,1
	union select 'HY-Brown',2,1
	union select 'Bovan Whites & Browns',3,1

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'ProductBreed' and c.name = 'NumberOfWeeks')
begin
	alter table ProductBreed add NumberOfWeeks int
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'ProductBreed' and c.name = 'WeeksHatchToHouse')
begin
	alter table ProductBreed add WeeksHatchToHouse int
	alter table ProductBreed alter column NumberOfWeeks numeric(19,2)
end

