
create PROC [dbo].[Get_UserGroupFromUserForSecurity]
	@UserID varchar(255) = NULL
AS
	SELECT ug.UserGroup
	FROM csb.UserTable ut
	INNER JOIN csb.UserGroup ug ON ut.UserGroupID = ug.UserGroupID
	WHERE ut.UserID = @UserID