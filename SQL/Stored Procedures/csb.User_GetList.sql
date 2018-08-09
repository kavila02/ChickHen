
CREATE PROCEDURE [csb].[User_GetList]
	@IncludeAll bit = 0
	, @UserTableID int = 0 
AS
	SELECT
		u.FullName
		, u.UserTableID
		, u.UserID
		, 2 AS Sequence
	FROM csb.[User] u
	WHERE @IncludeAll = 1 OR u.UserTableID = @UserTableID
	UNION
	SELECT
		'All'
		, 0
		, 0
		, 1 AS Sequence
	WHERE @IncludeAll = 1 OR @UserTableID = 0
	ORDER BY Sequence, FullName