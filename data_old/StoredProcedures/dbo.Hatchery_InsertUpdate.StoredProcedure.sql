if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Hatchery_InsertUpdate' and s.name = 'dbo')
begin
	drop proc Hatchery_InsertUpdate
end
GO
create proc Hatchery_InsertUpdate
	@I_vHatcheryID int
	,@I_vHatchery nvarchar(255)
	,@I_vSortOrder int = null
	,@I_vIsActive bit = 0
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vHatcheryID = 0
begin
	declare @HatcheryID table (HatcheryID int)
	insert into Hatchery (
		
		Hatchery
		, SortOrder
		, IsActive
	)
	output inserted.HatcheryID into @HatcheryID(HatcheryID)
	select
		
		@I_vHatchery
		,@I_vSortOrder
		,@I_vIsActive
	select top 1 @I_vHatcheryID = HatcheryID, @iRowID = HatcheryID from @HatcheryID
end
else
begin
	update Hatchery
	set
		
		Hatchery = @I_vHatchery
		,SortOrder = @I_vSortOrder
		,IsActive = @I_vIsActive
	where @I_vHatcheryID = HatcheryID
	select @iRowID = @I_vHatcheryID
end