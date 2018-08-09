create proc VaccineScheduleVaccine_Delete
	@I_vVaccineScheduleVaccineID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from VaccineScheduleVaccine where VaccineScheduleVaccineID = @I_vVaccineScheduleVaccineID