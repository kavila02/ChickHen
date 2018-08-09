
CREATE VIEW [csb].[User]
WITH SCHEMABINDING
AS
	SELECT
		UserID = u.UserTableID
		, UserTableID = u.UserTableID
		, UserGroupID = u.UserGroupID
		, UserName = u.UserID
		, FullName = u.ContactName
	FROM csb.UserTable u