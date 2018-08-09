
CREATE PROCEDURE [csb].[UserGroup_GetList]
AS
	SELECT
		UserGroupID
		, UserGroup
		, 1 AS Sequence
	FROM csb.UserGroup
	UNION
	SELECT
		0
		, ''
		, 2 AS Sequence
	ORDER BY Sequence, UserGroup