if not exists (select 1 from sys.tables where name = 'LayerHouse')
begin
create table LayerHouse
(
	LayerHouseID int primary key identity(1,1)
	,LocationID int foreign key references Location(LocationID)
	,LayerHouseName nvarchar(255)
	,YearBuilt nvarchar(50)
	,HouseStyle nvarchar(255)
	,CageHeight varchar(255)
	,CageWidth varchar(255)
	,CageDepth varchar(255)
	,CageSizeNotes nvarchar(255)
	,CubicInchesInCage varchar(255)
	,SquareInchesInCage varchar(255)
	,NumberCages varchar(255)
	,DrinkersPerCage int
	,BirdCapacity int
	,BirdCapacityBrown int
	,PEQAPNumber varchar(50)
	,BirdsPerHouse numeric(19,1)
	,SortOrder int
)
create nonclustered index IX_LayerHouse_LocationID
on LayerHouse(LocationID)
end

if exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'LayerHouse' and c.name = 'CageHeight' and system_type_id = 56)
begin
	alter table LayerHouse drop column CageHeight
	alter table LayerHouse add CageHeight numeric(19,5)
end
if exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'LayerHouse' and c.name = 'CageWidth' and system_type_id = 56)
begin
	alter table LayerHouse drop column CageWidth
	alter table LayerHouse add CageWidth numeric(19,5)
end
if exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'LayerHouse' and c.name = 'CageDepth' and system_type_id = 56)
begin
	alter table LayerHouse drop column CageDepth
	alter table LayerHouse add CageDepth numeric(19,5)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'LayerHouse' and c.name = 'PEQAPNumber' )
begin
	alter table LayerHouse add PEQAPNumber varchar(50)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'LayerHouse' and c.name = 'BirdCapacityBrown')
begin
	alter table LayerHouse add BirdCapacityBrown int
						,BirdsPerHouse numeric(19,1)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'LayerHouse' and c.name = 'SortOrder')
begin
	alter table LayerHouse add SortOrder int
end

if exists (select * from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'LayerHouse' and c.name = 'CageHeight' and system_type_id = 108)
begin
	alter table LayerHouse alter column CageHeight varchar(255)
	alter table LayerHouse alter column CageWidth varchar(255)
	alter table LayerHouse alter column CageDepth varchar(255)
	alter table LayerHouse alter column CageSizeNotes nvarchar(255)
	alter table LayerHouse alter column CubicInchesInCage varchar(255)
	alter table LayerHouse alter column SquareInchesInCage varchar(255)
	alter table LayerHouse alter column NumberCages varchar(255)
end


if not exists (select 1 from LayerHouse)
begin
	--1 manheim
	--2 mt pleasant
	--3 donegal

	insert into LayerHouse (LocationID, LayerHouseName, YearBuilt, HouseStyle, CageHeight, CageWidth, CageDepth, CageSizeNotes, CubicInchesInCage, SquareInchesInCage, NumberCages, DrinkersPerCage, BirdCapacity)
	select LocationID = 1
		, LayerHouseName = 'F-2 Brown'
		, YearBuilt = '2015'
		, HouseStyle = 'Dutchman Split Belt House Double Wide'
		, CageHeight = 20.5
		, CageWidth = 48
		, CageDepth = 31
		, CageSizeNotes = ''
		, CubicInchesInCage = 30504
		, SquareInchesInCage = 1488
		, NumberCages = 8784
		, DrinkersPerCage = 2
		, BirdCapacity = 60535
	union all
	select LocationID = 1
		, LayerHouseName = 'G Brown'
		, YearBuilt = '1996'
		, HouseStyle = 'Hi-Rise'
		, CageHeight = 16
		, CageWidth = 24
		, CageDepth = 20
		, CageSizeNotes = ''
		, CubicInchesInCage = 7680
		, SquareInchesInCage = 480
		, NumberCages = 13968
		, DrinkersPerCage = 1
		, BirdCapacity = 60535
	union all
	select LocationID = 1
		, LayerHouseName = HouseNumber
		, YearBuilt = 'Under Construction in 2015'
		, HouseStyle = 'Cage Free Colony Aviary'
		, CageHeight = null
		, CageWidth = null
		, CageDepth = null
		, CageSizeNotes = 'American Humane Certified Requirements'
		, CubicInchesInCage = null
		, SquareInchesInCage = null
		, NumberCages = null
		, DrinkersPerCage = null
		, BirdCapacity = 60535
		from (select 1 as something) a
			left outer join (select 'I-1' As HouseNumber union all select '2' As HouseNumber union all select '3' as HouseNumber) b on 1=1
	union all
	select LocationID = 2
		, LayerHouseName = HouseNumber
		, YearBuilt = '2003'
		, HouseStyle = 'Dutchman-Belt Single'
		, CageHeight = 16
		, CageWidth = 24
		, CageDepth = 25
		, CageSizeNotes = 'less 102 cubic inches for plenum'
		, CubicInchesInCage = 9408
		, SquareInchesInCage = 600
		, NumberCages = 26320
		, DrinkersPerCage = 1
		, BirdCapacity = 60535
		from (select 1 as something) a
			left outer join (select 'A' As HouseNumber union all 
							select 'B' As HouseNumber union all 
							select 'C' as HouseNumber union all 
							select 'D' as HouseNumber union all 
							select 'E' as HouseNumber union all 
							select 'F' as HouseNumber) b on 1=1
	union all
	select LocationID = 3
		, LayerHouseName = HouseNumber
		, YearBuilt = '1983'
		, HouseStyle = 'Hi-Rise'
		, CageHeight = 13.5
		, CageWidth = 24
		, CageDepth = 18
		, CageSizeNotes = 'Height- 14 front, 13 back. Depth- 16 top, 20 bottom'
		, CubicInchesInCage = 5832
		, SquareInchesInCage = 480
		, NumberCages = 9000
		, DrinkersPerCage = 1
		, BirdCapacity = 60535
		from (select 1 as something) a
			left outer join (select 'D' as HouseNumber union all 
							select 'E' as HouseNumber union all 
							select 'F' as HouseNumber) b on 1=1
	union all
	select LocationID = 3
		, LayerHouseName = 'C'
		, YearBuilt = '2008'
		, HouseStyle = 'Techno-Belt Quad'
		, CageHeight = 16
		, CageWidth = 48
		, CageDepth = 50.4
		, CageSizeNotes = ''
		, CubicInchesInCage = 38707
		, SquareInchesInCage = 2419
		, NumberCages = 10248
		, DrinkersPerCage = 4
		, BirdCapacity = 60535
end

