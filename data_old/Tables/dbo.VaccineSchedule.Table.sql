if not exists (select 1 from sys.tables where name = 'VaccineSchedule')
begin
	create table VaccineSchedule
	(
		VaccineScheduleID int primary key identity (1,1)
		,VaccineSchedule nvarchar(255)
		,SortOrder int
		,IsActive bit
	)
end