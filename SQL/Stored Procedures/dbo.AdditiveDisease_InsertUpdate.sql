



----------------------------------------------------------------------------------------

create proc [dbo].[AdditiveDisease_InsertUpdate]
	@I_vAdditiveDiseaseID int
	,@I_vAdditiveID int
	,@I_vDiseaseID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vAdditiveDiseaseID = 0
begin
	declare @AdditiveDiseaseID table (AdditiveDiseaseID int)
	insert into AdditiveDisease (
		
		AdditiveID
		, DiseaseID
	)
	output inserted.AdditiveDiseaseID into @AdditiveDiseaseID(AdditiveDiseaseID)
	select
		
		@I_vAdditiveID
		,@I_vDiseaseID
	select top 1 @I_vAdditiveDiseaseID = AdditiveDiseaseID, @iRowID = AdditiveDiseaseID from @AdditiveDiseaseID
end
else
begin
	update AdditiveDisease
	set
		
		AdditiveID = @I_vAdditiveID
		,DiseaseID = @I_vDiseaseID
	where @I_vAdditiveDiseaseID = AdditiveDiseaseID
	select @iRowID = @I_vAdditiveDiseaseID
end