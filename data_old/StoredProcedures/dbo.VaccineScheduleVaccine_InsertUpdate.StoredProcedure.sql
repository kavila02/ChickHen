if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'VaccineScheduleVaccine_InsertUpdate' and s.name = 'dbo')
begin
	drop proc VaccineScheduleVaccine_InsertUpdate
end
GO
create proc VaccineScheduleVaccine_InsertUpdate
	@I_vVaccineScheduleVaccineID int
	,@I_vVaccineScheduleID int
	,@I_vVaccineID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vVaccineScheduleVaccineID = 0
begin
	declare @VaccineScheduleVaccineID table (VaccineScheduleVaccineID int)
	insert into VaccineScheduleVaccine (
		
		VaccineScheduleID
		, VaccineID
	)
	output inserted.VaccineScheduleVaccineID into @VaccineScheduleVaccineID(VaccineScheduleVaccineID)
	select
		
		@I_vVaccineScheduleID
		,@I_vVaccineID
	select top 1 @I_vVaccineScheduleVaccineID = VaccineScheduleVaccineID, @iRowID = VaccineScheduleVaccineID from @VaccineScheduleVaccineID
end
else
begin
	update VaccineScheduleVaccine
	set
		
		VaccineScheduleID = @I_vVaccineScheduleID
		,VaccineID = @I_vVaccineID
	where @I_vVaccineScheduleVaccineID = VaccineScheduleVaccineID
	select @iRowID = @I_vVaccineScheduleVaccineID
end