if not exists (select 1 from sys.tables where name = 'FlockPulletGrower')
begin
create table FlockPulletGrower
(
	FlockPulletGrowerID int primary key identity(1,1)
	,FlockID int foreign key references Flock(FlockID)
	,PulletGrowerID int foreign key references PulletGrower(PulletGrowerID)
	,ExpectedNumberToHouse int
	,TotalHoused int
	,AgeAtHousing int --defaults to flock.(Ave Housing Date - Ave Hatch Date)
	,NPIP varchar(50)
)
end


if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockPulletGrower' and c.Name='ExpectedNumberToHouse')
begin
	alter table FlockPulletGrower add ExpectedNumberToHouse int
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockPulletGrower' and c.Name='TotalHoused')
begin
	alter table FlockPulletGrower add TotalHoused int
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockPulletGrower' and c.Name='AgeAtHousing')
begin
	alter table FlockPulletGrower add AgeAtHousing int
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockPulletGrower' and c.Name='NPIP')
begin
	alter table FlockPulletGrower add NPIP varchar(50)
end

