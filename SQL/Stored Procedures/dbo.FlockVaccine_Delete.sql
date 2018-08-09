
create proc [dbo].[FlockVaccine_Delete]
	@I_vFlockVaccineID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from FlockVaccine where FlockVaccineID = @I_vFlockVaccineID