if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'VaccineDisease_Delete' and s.name = 'dbo')
begin
	drop proc VaccineDisease_Delete
end
GO
create proc VaccineDisease_Delete
	@I_vVaccineDiseaseID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from VaccineDisease where VaccineDiseaseID = @I_vVaccineDiseaseID