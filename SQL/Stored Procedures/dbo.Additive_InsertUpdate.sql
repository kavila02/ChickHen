create proc Additive_InsertUpdate
	@I_vAdditiveID int
	,@I_vAdditive nvarchar(100) = ''
	,@I_vApprovedForColony bit = 0
	,@I_vApprovedForAviary bit = 0
	,@I_vApprovedForOrganic bit = 0
	,@I_vIsActive bit = 1
	,@I_vSortOrder int = null
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vAdditiveID = 0
begin
	declare @AdditiveID table (AdditiveID int)
	insert into Additive (
		
		Additive
		, ApprovedForColony
		, ApprovedForAviary
		, ApprovedForOrganic
		, IsActive
		, SortOrder
	)
	output inserted.AdditiveID into @AdditiveID(AdditiveID)
	select
		
		@I_vAdditive
		,@I_vApprovedForColony
		,@I_vApprovedForAviary
		,@I_vApprovedForOrganic
		,@I_vIsActive
		,@I_vSortOrder
	select top 1 @I_vAdditiveID = AdditiveID, @iRowID = AdditiveID from @AdditiveID
end
else
begin
	update Additive
	set
		
		Additive = @I_vAdditive
		,ApprovedForColony = @I_vApprovedForColony
		,ApprovedForAviary = @I_vApprovedForAviary
		,ApprovedForOrganic = @I_vApprovedForOrganic
		,IsActive = @I_vIsActive
		,SortOrder = @I_vSortOrder
	where @I_vAdditiveID = AdditiveID
	select @iRowID = @I_vAdditiveID
end