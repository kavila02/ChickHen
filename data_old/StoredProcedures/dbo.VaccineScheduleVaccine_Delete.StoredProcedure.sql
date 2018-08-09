if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'VaccineScheduleVaccine_Delete' and s.name = 'dbo')
begin
	drop proc VaccineScheduleVaccine_Delete
end
GO
create proc VaccineScheduleVaccine_Delete
	@I_vVaccineScheduleVaccineID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from VaccineScheduleVaccine where VaccineScheduleVaccineID = @I_vVaccineScheduleVaccineID