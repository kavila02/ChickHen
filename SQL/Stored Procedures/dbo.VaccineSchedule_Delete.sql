create proc VaccineSchedule_Delete
	@I_vVaccineScheduleID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

delete from VaccineScheduleVaccine where VaccineScheduleID = @I_vVaccineScheduleID
delete from VaccineSchedule where VaccineScheduleID = @I_vVaccineScheduleID