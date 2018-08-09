if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'VaccineSchedule_Delete' and s.name = 'dbo')
begin
	drop proc VaccineSchedule_Delete
end
GO
create proc VaccineSchedule_Delete
	@I_vVaccineScheduleID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

delete from VaccineScheduleVaccine where VaccineScheduleID = @I_vVaccineScheduleID
delete from VaccineSchedule where VaccineScheduleID = @I_vVaccineScheduleID