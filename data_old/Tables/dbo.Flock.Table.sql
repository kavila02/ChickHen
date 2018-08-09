if not exists (select 1 from sys.tables where name = 'Flock')
begin
create table Flock
(
	FlockID int primary key identity(1,1)
	,FlockName nvarchar(255)
	,LayerHouseID int foreign key references LayerHouse(LayerHouseID)
	
	--Step1 Fields
	,ProductBreedID int foreign key references ProductBreed(ProductBreedID)
	,OrderNumber varchar(50)

	,HatchDate_First date
	,HatchDate_Last date
	,HatchDate_Average date --as dateadd(d,datediff(d,HatchDate_First,HatchDate_Last)/2,HatchDate_First)
	
	,Quantity int
	,ServicesNotes nvarchar(1000)

	--Step 2 Fields
	,FlockNumber varchar(15) --Is this needed? Or can we use the FlockID field?
	,OldOutDate date --Once we're capturing all flocks, this will auto-populate from previous flock in layer house. should be 15 weeks after hatch date
	,FowlOutID int foreign key references FowlOutMover(FowlOutMoverID)

	,HousingDate_First date --first date chicks are delivered to house

	,PulletsMovedID int foreign key references PulletMover(PulletMoverID)
	,NumberChicksOrdered int
	--,AgeAtHSGInWeeks calculated from days
	--,AgeAtHSG int --days, calculated (Ave Housing Date - Ave Hatch Date)
	--,FowlAge int calculated by OldOutDate - OldFowlHatchDate
	,OldFowlHatchDate date --Once we're capturing all flocks, this will auto-populate from previous flock in layer house

	--Step 3 Fields
	,ServiceTechID int foreign key references Contact(ContactID)

	--Step 5 Fields
	--Most of these fields seem order related, and there are multiple orders to a flock
	--For now we are not capturing any of this data, just allowing for uploads

	--Step 12 Fields
	,HousingDate_Last date --last date chicks are delivered to house
	,HousingDate_Average date --as dateadd(d,datediff(d,HousingDate_First,HousingDate_Last)/2,HousingDate_First)
	,TotalHoused int --default to sum(FlockPulletGrower.TotalHoused)
	
	--step 21-23 fields
	,HousingOutDate date --should be 15 weeks after the hatch date of the next flock
	,FowlRemoved bit


	--------------------
	--,NPIP varchar(50)
	
	,HatcheryID int foreign key references Hatchery(HatcheryID)
	,ChickPlacementDate date
	,TotalChicksPlaced int

	,CreatedDate datetime default GETDATE()
)
create nonclustered index IX_Flock_LayerHouseID
on Flock(LayerHouseID)
end

GO

if exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='PulletFarm')
begin
	alter table Flock drop column PulletFarm
end

if exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='ExpectedNumberToHouse')
begin
	alter table Flock drop column ExpectedNumberToHouse
end

--if exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='TotalHoused')
--begin
--	alter table Flock drop column TotalHoused
--end

if exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='HatchDate')
begin
	alter table Flock drop column HatchDate
end

if exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='HousingStartDate')
begin
	alter table Flock drop column HousingStartDate
end

if exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='HousingEndDate')
begin
	alter table Flock drop column HousingEndDate
end

if exists (select 1 from sys.foreign_key_columns fk
				inner join sys.tables t on fk.parent_object_id = t.object_id and t.name = 'Flock'
				inner join sys.columns c on fk.parent_object_id = c.object_id and fk.parent_column_id = c.column_id and c.name = 'FowlOutID'
				inner join sys.tables t2 on fk.referenced_object_id = t2.object_id and t2.name = 'PulletMover'
				inner join sys.columns c2 on fk.referenced_object_id = c2.object_id and fk.referenced_column_id = c2.column_id and c2.name = 'PulletMoverID'
				inner join sys.foreign_keys fk2 on fk.constraint_object_id = fk2.object_id)
begin
	declare @sql nvarchar(500)
	select @sql = 'alter table Flock drop constraint ' + rtrim(fk2.name)
	from sys.foreign_key_columns fk
				inner join sys.tables t on fk.parent_object_id = t.object_id and t.name = 'Flock'
				inner join sys.columns c on fk.parent_object_id = c.object_id and fk.parent_column_id = c.column_id and c.name = 'FowlOutID'
				inner join sys.tables t2 on fk.referenced_object_id = t2.object_id and t2.name = 'PulletMover'
				inner join sys.columns c2 on fk.referenced_object_id = c2.object_id and fk.referenced_column_id = c2.column_id and c2.name = 'PulletMoverID'
				inner join sys.foreign_keys fk2 on fk.constraint_object_id = fk2.object_id
	exec (@sql)
	alter table Flock drop column FowlOutID
	alter table Flock add FowlOutID int foreign key references FowlOutMover(FowlOutMoverID)
end

if exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='FowlAge')
begin
	alter table Flock drop column FowlAge
end


---add
if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='HatchDate_First')
begin
	alter table Flock add HatchDate_First date 
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='HatchDate_Last')
begin
	alter table Flock add HatchDate_Last date
end
go
if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='HatchDate_Average')
begin
	alter table Flock add HatchDate_Average as dateadd(d,datediff(d,HatchDate_First,HatchDate_Last)/2,HatchDate_First)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='HousingDate_First')
begin
	alter table Flock add HousingDate_First date
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='HousingDate_Last')
begin
	alter table Flock add HousingDate_Last date
end
go
if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='HousingDate_Average')
begin
	alter table Flock add HousingDate_Average as dateadd(d,datediff(d,HousingDate_First,HousingDate_Last)/2,HousingDate_First)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='OrderNumber')
begin
	alter table Flock add OrderNumber varchar(50)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='NPIP')
begin
	alter table Flock add NPIP varchar(50)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='TotalHoused')
begin
	alter table Flock add TotalHoused int
end


if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='HatcheryID')
begin
	alter table Flock add HatcheryID int foreign key references Hatchery(HatcheryID)
end
if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='ChickPlacementDate')
begin
	alter table Flock add ChickPlacementDate date
end
if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='TotalChicksPlaced')
begin
	alter table Flock add TotalChicksPlaced int
end

if  exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='NPIP')
begin
	alter table Flock drop column NPIP
end


if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name='CreatedDate')
begin
	alter table Flock add CreatedDate datetime default GETDATE()
end

if exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name = 'HatchDate_Average' and is_computed = 1)
begin
	alter table Flock drop column HatchDate_Average
end
go
if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name = 'HatchDate_Average')
begin
	alter table Flock add HatchDate_Average date
end
go
if not exists (select 1 from Flock where HatchDate_Average is not null)
begin
	update Flock set HatchDate_Average = dateadd(d,datediff(d,HatchDate_First,HatchDate_Last)/2,HatchDate_First)
end
go
if exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name = 'HousingDate_Average' and is_computed = 1)
begin
	alter table Flock drop column HousingDate_Average
end
go
if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Flock' and c.Name = 'HousingDate_Average')
begin
	alter table Flock add HousingDate_Average date
end
go
if not exists (select 1 from Flock where HousingDate_Average is not null)
begin
	update Flock set HousingDate_Average = dateadd(d,datediff(d,HousingDate_First,HousingDate_Last)/2,HousingDate_First)
end
go