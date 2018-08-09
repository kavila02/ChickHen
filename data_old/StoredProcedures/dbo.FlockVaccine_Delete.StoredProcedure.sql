if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockVaccine_Delete' and s.name = 'dbo')
begin
	drop proc FlockVaccine_Delete
end
GO
create proc FlockVaccine_Delete
	@I_vFlockVaccineID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from FlockVaccine where FlockVaccineID = @I_vFlockVaccineID