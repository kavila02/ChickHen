if not exists (select 1 from sys.tables where name = 'PulletGrower')
begin
create table PulletGrower
(
	PulletGrowerID int primary key identity(1,1)
	,PulletGrower nvarchar(255)
	,Address varchar(100)
	,City varchar(50)
	,State varchar(25)
	,Zip varchar(10)
	,Capacity int
	,SortOrder int
	,IsActive bit
	,Longitude numeric(19,5)
	,Latitude numeric(19,5)
	,Phone varchar(20)

)
end

If not exists (select 1 from PulletGrower)
	insert into PulletGrower (PulletGrower, Capacity, SortOrder, IsActive)
	select 'Rohrer #2',205000,1,1
	union select 'Rohrer #4',205000,2,1
	union select 'K. Sweigart',278000,3,1
	union select 'R. Andrews #1',278000,4,1
	union select 'R. Andrews #2',226000,5,1
	union select 'S. Hershey',245000,6,1
	union select 'J. Yohe #2',230000,7,1
	union select 'J. Yohe #1',65000,8,1
	union select 'D. Landis #1',226000,9,1
	union select 'B. Doutrich #1',226000,10,1
	union select 'K. Meck #1',112000,11,1
	union select 'K. Meck #2',157000,12,1
	union select 'Weaver Farm',88000,13,1
	union select 'R. Martin',35000,14,1
	union select 'Mecks Produce',112000,98,0
	union select 'Chick Valley #1',108000,99,0
	union select 'Chick Valley #2',68000,100,0

	
if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'PulletGrower' and c.Name='Capacity')
begin
	alter table PulletGrower add Capacity int
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'PulletGrower' and c.Name='Address')
begin
	alter table PulletGrower add Address varchar(100)
	,City varchar(50)
	,State varchar(25)
	,Zip varchar(10)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'PulletGrower' and c.Name='Longitude')
begin
	alter table PulletGrower add Longitude numeric(19,5)
	,Latitude numeric(19,5)
	,Phone varchar(20)
end
