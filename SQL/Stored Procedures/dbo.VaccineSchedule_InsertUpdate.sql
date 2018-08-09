create proc VaccineSchedule_InsertUpdate
	@I_vVaccineScheduleID int
	,@I_vVaccineSchedule nvarchar(255)
	,@I_vSortOrder int = null
	,@I_vIsActive bit = 1
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vVaccineScheduleID = 0
begin
	declare @VaccineScheduleID table (VaccineScheduleID int)
	insert into VaccineSchedule (
		
		VaccineSchedule
		, SortOrder
		, IsActive
	)
	output inserted.VaccineScheduleID into @VaccineScheduleID(VaccineScheduleID)
	select
		
		@I_vVaccineSchedule
		,@I_vSortOrder
		,@I_vIsActive
	select top 1 @I_vVaccineScheduleID = VaccineScheduleID, @iRowID = VaccineScheduleID from @VaccineScheduleID
end
else
begin
	update VaccineSchedule
	set
		
		VaccineSchedule = @I_vVaccineSchedule
		,SortOrder = @I_vSortOrder
		,IsActive = @I_vIsActive
	where @I_vVaccineScheduleID = VaccineScheduleID
	select @iRowID = @I_vVaccineScheduleID
end