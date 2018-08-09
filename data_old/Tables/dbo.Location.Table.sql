if not exists (select 1 from sys.tables where name = 'Location')
begin
create table Location
(
	LocationID int primary key identity(1,1)
	,Location nvarchar(255)

	,AddressName nvarchar(255)
	,Address1 varchar(255)
	,Address2 varchar(255)
	,Address3 varchar(255)
	,City varchar(50)
	,State varchar(50)
	,Zip varchar(50)
	,PhoneNumber1 varchar(20)

	,LocationAbbreviation nvarchar(10)
	,USDAPlantNumber1 varchar(50)
	,USDAPlantNumber2 varchar(50)
	,PDANumber varchar(50)
	,PDAPremiseID varchar(50)
	--,PEQAPHouseNumber --belongs on flock??

	,FolderName varchar(50)
)
end


if not exists (select 1 from Location)
begin
	set identity_insert Location on
	insert into Location (LocationID, Location, AddressName)
	select 1,'Manheim','Main'
	union select 2,'Mount Pleasant','Main'
	union select 3,'Donegal','Main'
	set identity_insert Location off
end

if not exists (select 1 from sys.tables t inner join sys.columns c on t.object_id = c.object_id where t.name = 'Location' and c.name = 'LocationAbbreviation')
begin
	alter table Location add LocationAbbreviation nvarchar(10)
end

if not exists (select 1 from sys.tables t inner join sys.columns c on t.object_id = c.object_id where t.name = 'Location' and c.name = 'USDAPlantNumber1')
begin
	alter table Location add USDAPlantNumber1 varchar(50)
	,USDAPlantNumber2 varchar(50)
	,PDANumber varchar(50)
	,PDAPremiseID varchar(50)
end

GO

if not exists (select 1 from sys.tables t inner join sys.columns c on t.object_id = c.object_id where t.name = 'Location' and c.name = 'FolderName')
begin
	alter table Location add FolderName varchar(50)
end