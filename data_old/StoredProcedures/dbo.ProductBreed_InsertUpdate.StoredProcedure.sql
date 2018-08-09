if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ProductBreed_InsertUpdate' and s.name = 'dbo')
begin
	drop proc ProductBreed_InsertUpdate
end
GO




create proc ProductBreed_InsertUpdate
	@I_vProductBreedID int
	,@I_vProductBreed nvarchar(255) = ''
	,@I_vNumberOfWeeks numeric(19,2) = null
	,@I_vWeeksHatchToHouse numeric(19,2) = null
	,@I_vSortOrder int = null
	,@I_vIsActive bit = 1
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vProductBreedID = 0
begin
	insert into ProductBreed (
		
		ProductBreed
		, NumberOfWeeks
		, WeeksHatchToHouse
		, SortOrder
		, IsActive
	)
	select
		
		@I_vProductBreed
		,@I_vNumberOfWeeks
		,@I_vWeeksHatchToHouse
		,@I_vSortOrder
		,@I_vIsActive
end
else
begin
	update ProductBreed
	set
		
		ProductBreed = @I_vProductBreed
		,NumberOfWeeks = @I_vNumberOfWeeks
		,WeeksHatchToHouse = @I_vWeeksHatchToHouse
		,SortOrder = @I_vSortOrder
		,IsActive = @I_vIsActive
	where @I_vProductBreedID = ProductBreedID
end