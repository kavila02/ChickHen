if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockContact_InsertUpdate' and s.name = 'dbo')
begin
	drop proc FlockContact_InsertUpdate
end
GO

create proc FlockContact_InsertUpdate
	@I_vFlockContactID int
	,@I_vFlockID int
	,@I_vContactRoleID int = null
	,@I_vContactID int = null
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vFlockContactID = 0
begin
	insert into FlockContact (
		
		FlockID
		, ContactRoleID
		, ContactID
	)
	select
		
		@I_vFlockID
		,@I_vContactRoleID
		,@I_vContactID
end
else
begin
	update FlockContact
	set
		
		FlockID = @I_vFlockID
		,ContactRoleID = @I_vContactRoleID
		,ContactID = @I_vContactID
	where @I_vFlockContactID = FlockContactID
end