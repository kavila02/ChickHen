if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'PulletMover_InsertUpdate' and s.name = 'dbo')
begin
	drop proc PulletMover_InsertUpdate
end
GO




create proc PulletMover_InsertUpdate
	@I_vPulletMoverID int
	,@I_vPulletMover nvarchar(255) = ''
	,@I_vSortOrder int = null
	,@I_vIsActive bit = 1
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vPulletMoverID = 0
begin
	insert into PulletMover (
		
		PulletMover
		, SortOrder
		, IsActive
	)
	select
		
		@I_vPulletMover
		,@I_vSortOrder
		,@I_vIsActive
end
else
begin
	update PulletMover
	set
		
		PulletMover = @I_vPulletMover
		,SortOrder = @I_vSortOrder
		,IsActive = @I_vIsActive
	where @I_vPulletMoverID = PulletMoverID
end