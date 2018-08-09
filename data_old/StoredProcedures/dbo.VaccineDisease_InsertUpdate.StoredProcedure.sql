if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'VaccineDisease_InsertUpdate' and s.name = 'dbo')
begin
	drop proc VaccineDisease_InsertUpdate
end
GO
create proc VaccineDisease_InsertUpdate
	@I_vVaccineDiseaseID int
	,@I_vVaccineID int
	,@I_vDiseaseID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vVaccineDiseaseID = 0
begin
	declare @VaccineDiseaseID table (VaccineDiseaseID int)
	insert into VaccineDisease (
		
		VaccineID
		, DiseaseID
	)
	output inserted.VaccineDiseaseID into @VaccineDiseaseID(VaccineDiseaseID)
	select
		
		@I_vVaccineID
		,@I_vDiseaseID
	select top 1 @I_vVaccineDiseaseID = VaccineDiseaseID, @iRowID = VaccineDiseaseID from @VaccineDiseaseID
end
else
begin
	update VaccineDisease
	set
		
		VaccineID = @I_vVaccineID
		,DiseaseID = @I_vDiseaseID
	where @I_vVaccineDiseaseID = VaccineDiseaseID
	select @iRowID = @I_vVaccineDiseaseID
end