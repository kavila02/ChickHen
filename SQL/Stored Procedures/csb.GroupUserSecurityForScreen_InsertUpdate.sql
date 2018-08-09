
create proc csb.GroupUserSecurityForScreen_InsertUpdate
@I_vUserGroupPagePartID int
,@I_vPagePartID int
,@I_vUserGroupID int
,@I_vEffectivePermission varchar(10)
,@O_iErrorState int=0 output
,@oErrString varchar(255)='' output
,@iRowID varchar(255)=NULL output
AS

if @I_vUserGroupPagePartID = 0
begin
	insert into csb.UserGroupPagePart (UserGroupID, PagePartID, IsViewable, IsUpdatable)
	select
		@I_vUserGroupID
		,@I_vPagePartID
		,case when @I_vEffectivePermission = 'No Access' then 0 else 1 end
		,case when @I_vEffectivePermission = 'Read/Write' then 1 else 0 end
end
else
begin
	update csb.UserGroupPagePart
	set
		IsViewable = case when @I_vEffectivePermission = 'No Access' then 0 else 1 end
		,IsUpdatable = case when @I_vEffectivePermission = 'Read/Write' then 1 else 0 end
	where UserGroupPagePartID = @I_vUserGroupPagePartID
end