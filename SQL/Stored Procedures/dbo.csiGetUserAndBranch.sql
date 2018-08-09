
CREATE PROC [dbo].[csiGetUserAndBranch]
	@UserName varchar(150)
AS
	DECLARE @DATA TABLE (
		UserName varchar(255)
		, CanChangeBranch bit
	)
	INSERT INTO @DATA
	SELECT
		ISNULL((SELECT (CASE ContactName 
							WHEN '' THEN SUBSTRING(UserID, CHARINDEX('\', UserID)+1, LEN(UserID))
							ELSE ContactName 
						   END) AS UserName
				FROM csb.UserTable u with (nolock)
				WHERE UserID = @UserName ), @UserName)
		, 0


	SELECT TOP 1 
		ISNULL((SELECT UserName FROM @DATA), @UserName) AS UserName
		, ISNULL((SELECT CanChangeBranch FROM @DATA), 0) AS CanChangeBranch