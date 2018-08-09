

create procedure [csb].[UserGroup_Delete]
@I_vUserGroupID int
, @O_iErrorState int=0 output 
, @oErrString varchar(255)='' output
, @iRowID int=0 output
AS

delete from csb.UserGroup where UserGroupID = @I_vUserGroupID