create proc Disease_InsertUpdate
	@I_vDiseaseID int
	,@I_vDiseaseName varchar(100)
	,@I_vSortOrder int
	,@I_vIsActive bit
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vDiseaseID = 0
begin
	declare @DiseaseID table (DiseaseID int)
	insert into Disease (
		
		DiseaseName
		, SortOrder
		, IsActive
	)
	output inserted.DiseaseID into @DiseaseID(DiseaseID)
	select
		
		@I_vDiseaseName
		,@I_vSortOrder
		,@I_vIsActive
	select top 1 @I_vDiseaseID = DiseaseID, @iRowID = DiseaseID from @DiseaseID
end
else
begin
	update Disease
	set
		
		DiseaseName = @I_vDiseaseName
		,SortOrder = @I_vSortOrder
		,IsActive = @I_vIsActive
	where @I_vDiseaseID = DiseaseID
	select @iRowID = @I_vDiseaseID
end