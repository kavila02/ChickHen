if not exists (select 1 from sys.tables where name = 'VaccineScheduleVaccine')
begin
	create table VaccineScheduleVaccine
	(
		VaccineScheduleVaccineID int primary key identity(1,1)
		,VaccineScheduleID int foreign key references VaccineSchedule(VaccineScheduleID)
		,VaccineID int foreign key references Vaccine(VaccineID)
	)
end

create nonclustered index IX_VaccineScheduleVaccine_VaccineScheduleID
on VaccineScheduleVaccine(VaccineScheduleID)
create nonclustered index IX_VaccineScheduleVaccine_VaccineID
on VaccineScheduleVaccine(VaccineID)