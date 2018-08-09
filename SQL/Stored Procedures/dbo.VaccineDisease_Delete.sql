create proc VaccineDisease_Delete
	@I_vVaccineDiseaseID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from VaccineDisease where VaccineDiseaseID = @I_vVaccineDiseaseID