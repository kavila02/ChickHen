

CREATE PROCEDURE [csb].[UserGroup_GetSelectList]
AS
	SELECT
	   UserGroup
	   , UserGroupID
	FROM csb.UserGroup
	ORDER BY UserGroup