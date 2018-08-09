
create procedure [csb].[UserGroup_InsertUpdate]
@I_vUserGroupID int
,@I_vUserGroup nvarchar(255)
, @O_iErrorState int=0 output 
, @oErrString varchar(255)='' output
, @iRowID int=0 output
AS

If @I_vUserGroupID = 0
begin
	insert into csb.UserGroup (UserGroup)
		select @I_vUserGroup
	select @I_vUserGroupID = SCOPE_IDENTITY(), @iRowID = SCOPE_IDENTITY()
end
else
begin
	update csb.UserGroup
	set UserGroup = @I_vUserGroup
	where UserGroupID = @I_vUserGroupID

	select @iRowID = @I_vUserGroupID
end