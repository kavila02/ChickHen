if not exists (select 1 from sys.tables where name = 'FlockVaccine')
begin
create table FlockVaccine
(
	FlockVaccineID int primary key identity(1,1)
	,FlockID int foreign key references Flock(FlockID)
	,VaccineID int foreign key references Vaccine(VaccineID)
	,VaccineStatusID int foreign key references VaccineStatus(VaccineStatusID)
	,FlockVaccineNotes nvarchar(4000)

	,ScheduledDate date
	,CompletedDate date
)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockVaccine' and c.name = 'ScheduledDate')
begin
	alter table FlockVaccine add ScheduledDate date
end
if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockVaccine' and c.name = 'CompletedDate')
begin
	alter table FlockVaccine add CompletedDate date
end