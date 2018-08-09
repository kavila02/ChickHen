if not exists (select 1 from sys.tables where name = 'VaccineStatus')
begin
create table VaccineStatus
(
	VaccineStatusID int primary key identity(1,1)
	,VaccineStatus nvarchar(50)
	,SortOrder smallint
	,IsActive bit
)
end

if not exists (select 1 from VaccineStatus)
	insert into VaccineStatus (VaccineStatus, SortOrder, IsActive)
		select 'Not Started',1,1
		union select 'Scheduled',2,1
		union select 'In Progress',3,1
		union select 'Deferred',4,1
		union select 'Complete',5,1