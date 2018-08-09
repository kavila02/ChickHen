if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ContactRole_InsertUpdate' and s.name = 'dbo')
begin
	drop proc ContactRole_InsertUpdate
end
GO


create proc ContactRole_InsertUpdate
	@I_vContactRoleID int
	,@I_vRoleName nvarchar(255) = ''
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vContactRoleID = 0
begin
	insert into ContactRole (
		
		RoleName
	)
	select
		
		@I_vRoleName
end
else
begin
	update ContactRole
	set
		
		RoleName = @I_vRoleName
	where @I_vContactRoleID = ContactRoleID
end