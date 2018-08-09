




create proc Vaccine_InsertUpdate
	@I_vVaccineID int
	,@I_vVaccineName nvarchar(255) = ''
	,@I_vActiveStartDate date = null
	,@I_vActiveEndDate date = null
	,@I_vReplacementVaccineID int = null
	,@I_vSortOrder int = null
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

if IsNull(@I_vActiveEndDate,'1/1/1900') = '1/1/1900'
	select @I_vActiveEndDate = NULL

if @I_vVaccineID = 0
begin
	insert into Vaccine (
		
		VaccineName
		, ActiveStartDate
		, ActiveEndDate
		, ReplacementVaccineID
		, SortOrder
	)
	select
		
		@I_vVaccineName
		,@I_vActiveStartDate
		,@I_vActiveEndDate
		,@I_vReplacementVaccineID
		,@I_vSortOrder
end
else
begin
	update Vaccine
	set
		
		VaccineName = @I_vVaccineName
		,ActiveStartDate = @I_vActiveStartDate
		,ActiveEndDate = @I_vActiveEndDate
		,ReplacementVaccineID = @I_vReplacementVaccineID
		,SortOrder = @I_vSortOrder
	where @I_vVaccineID = VaccineID
end