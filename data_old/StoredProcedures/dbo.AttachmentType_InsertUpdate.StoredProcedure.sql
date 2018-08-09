if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'AttachmentType_InsertUpdate' and s.name = 'dbo')
begin
	drop proc AttachmentType_InsertUpdate
end
GO
create proc AttachmentType_InsertUpdate
	@I_vAttachmentTypeID int
	,@I_vAttachmentType nvarchar(255)
	,@I_vSortOrder int
	,@I_vIsActive bit
	,@I_vShowOnScreenID smallint
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vAttachmentTypeID = 0
begin
	declare @AttachmentTypeID table (AttachmentTypeID int)
	insert into AttachmentType (
		
		AttachmentType
		, SortOrder
		, IsActive
		, ShowOnScreenID
	)
	output inserted.AttachmentTypeID into @AttachmentTypeID(AttachmentTypeID)
	select
		
		@I_vAttachmentType
		,@I_vSortOrder
		,@I_vIsActive
		,@I_vShowOnScreenID
	select top 1 @I_vAttachmentTypeID = AttachmentTypeID, @iRowID = AttachmentTypeID from @AttachmentTypeID
end
else
begin
	update AttachmentType
	set
		
		AttachmentType = @I_vAttachmentType
		,SortOrder = @I_vSortOrder
		,IsActive = @I_vIsActive
		,ShowOnScreenID = @I_vShowOnScreenID
	where @I_vAttachmentTypeID = AttachmentTypeID
	select @iRowID = @I_vAttachmentTypeID
end