create proc FlockChecklist_Detail_Vaccine_InsertUpdate
	@I_vFlockChecklist_Detail_VaccineID int
	,@I_vFlockChecklist_DetailID int
	,@I_vVaccineID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vFlockChecklist_Detail_VaccineID = 0
begin
	declare @FlockChecklist_Detail_VaccineID table (FlockChecklist_Detail_VaccineID int)
	insert into FlockChecklist_Detail_Vaccine (
		
		FlockChecklist_DetailID
		, VaccineID
	)
	output inserted.FlockChecklist_Detail_VaccineID into @FlockChecklist_Detail_VaccineID(FlockChecklist_Detail_VaccineID)
	select
		
		@I_vFlockChecklist_DetailID
		,@I_vVaccineID
	select top 1 @I_vFlockChecklist_Detail_VaccineID = FlockChecklist_Detail_VaccineID, @iRowID = FlockChecklist_Detail_VaccineID from @FlockChecklist_Detail_VaccineID

	--add any new vaccines to the flock if they don't already exist
	--And insert those vaccines into the flock with a status of scheduled
	insert into FlockVaccine (FlockID, VaccineID, VaccineStatusID, FlockVaccineNotes, ScheduledDate, CompletedDate)
	select
		fc.FlockID
		,dv.VaccineID
		,(select top 1 VaccineStatusID from VaccineStatus where VaccineStatus like '%scheduled%')
		,d.ActionDescription
		,d.DateOfAction
		,NULL
	from FlockChecklist_Detail_Vaccine dv
		inner join FlockChecklist_Detail d on dv.FlockChecklist_DetailID = d.FlockChecklist_DetailID
		inner join FlockChecklist fc on d.FlockChecklistID = fc.FlockChecklistID
		--where not already exists that particular vaccine scheduled for that given day
		left outer join FlockVaccine fv on fv.VaccineID = dv.VaccineID and d.DateOfAction = fv.ScheduledDate and fv.FlockID = fc.FlockID
	where dv.FlockChecklist_Detail_VaccineID = @I_vFlockChecklist_Detail_VaccineID
	and fv.FlockVaccineID is null
end
else
begin
	update FlockChecklist_Detail_Vaccine
	set
		
		FlockChecklist_DetailID = @I_vFlockChecklist_DetailID
		,VaccineID = @I_vVaccineID
	where @I_vFlockChecklist_Detail_VaccineID = FlockChecklist_Detail_VaccineID
	select @iRowID = @I_vFlockChecklist_Detail_VaccineID
end