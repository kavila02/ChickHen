if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Checklist_DetailType_InsertUpdate' and s.name = 'dbo')
begin
	drop proc Checklist_DetailType_InsertUpdate
end
GO
create proc Checklist_DetailType_InsertUpdate
	@I_vChecklist_DetailTypeID int
	,@I_vChecklist_DetailType nvarchar(255) = ''
	,@I_vSortOrder int = null
	,@I_vActive bit = 1
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vChecklist_DetailTypeID = 0
begin
	declare @Checklist_DetailTypeID table (Checklist_DetailTypeID int)
	insert into Checklist_DetailType (
		
		Checklist_DetailType
		, SortOrder
		, Active
	)
	output inserted.Checklist_DetailTypeID into @Checklist_DetailTypeID(Checklist_DetailTypeID)
	select
		
		@I_vChecklist_DetailType
		,@I_vSortOrder
		,@I_vActive
	select top 1 @I_vChecklist_DetailTypeID = Checklist_DetailTypeID, @iRowID = Checklist_DetailTypeID from @Checklist_DetailTypeID
end
else
begin
	update Checklist_DetailType
	set
		
		Checklist_DetailType = @I_vChecklist_DetailType
		,SortOrder = @I_vSortOrder
		,Active = @I_vActive
	where @I_vChecklist_DetailTypeID = Checklist_DetailTypeID
	select @iRowID = @I_vChecklist_DetailTypeID
end