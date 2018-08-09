create proc ChecklistTemplate_Detail_Vaccine_InsertUpdate
	@I_vChecklistTemplate_Detail_VaccineID int
	,@I_vChecklistTemplate_DetailID int
	,@I_vVaccineID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vChecklistTemplate_Detail_VaccineID = 0
begin
	declare @ChecklistTemplate_Detail_VaccineID table (ChecklistTemplate_Detail_VaccineID int)
	insert into ChecklistTemplate_Detail_Vaccine (
		
		ChecklistTemplate_DetailID
		, VaccineID
	)
	output inserted.ChecklistTemplate_Detail_VaccineID into @ChecklistTemplate_Detail_VaccineID(ChecklistTemplate_Detail_VaccineID)
	select
		
		@I_vChecklistTemplate_DetailID
		,@I_vVaccineID
	select top 1 @I_vChecklistTemplate_Detail_VaccineID = ChecklistTemplate_Detail_VaccineID, @iRowID = ChecklistTemplate_Detail_VaccineID from @ChecklistTemplate_Detail_VaccineID
end
else
begin
	update ChecklistTemplate_Detail_Vaccine
	set
		
		ChecklistTemplate_DetailID = @I_vChecklistTemplate_DetailID
		,VaccineID = @I_vVaccineID
	where @I_vChecklistTemplate_Detail_VaccineID = ChecklistTemplate_Detail_VaccineID
	select @iRowID = @I_vChecklistTemplate_Detail_VaccineID
end