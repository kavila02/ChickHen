if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Detail_Status_InsertUpdate' and s.name = 'dbo')
begin
	drop proc Detail_Status_InsertUpdate
end
GO
create proc Detail_Status_InsertUpdate
	@I_vDetail_StatusID int
	,@I_vDetail_Status nvarchar(255) = ''
	,@I_vSortOrder int = 0
	,@I_vIsActive bit = 1
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vDetail_StatusID = 0
begin
	declare @Detail_StatusID table (Detail_StatusID int)
	insert into Detail_Status (
		
		Detail_Status
		, SortOrder
		, IsActive
	)
	output inserted.Detail_StatusID into @Detail_StatusID(Detail_StatusID)
	select
		
		@I_vDetail_Status
		,@I_vSortOrder
		,@I_vIsActive
	select top 1 @I_vDetail_StatusID = Detail_StatusID, @iRowID = Detail_StatusID from @Detail_StatusID
end
else
begin
	update Detail_Status
	set
		
		Detail_Status = @I_vDetail_Status
		,SortOrder = @I_vSortOrder
		,IsActive = @I_vIsActive
	where @I_vDetail_StatusID = Detail_StatusID
	select @iRowID = @I_vDetail_StatusID
end