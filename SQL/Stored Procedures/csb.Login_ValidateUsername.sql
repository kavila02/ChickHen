
CREATE PROC [csb].[Login_ValidateUsername]
    @UserName varchar(255)
AS

DECLARE @UserSalt varchar(8000) = NULL

SELECT TOP 1 @UserSalt = UserPasswordSalt 
FROM csb.UserTable u
INNER JOIN csb.UserLoginTable l ON u.UserTableID = l.UserTableID
WHERE u.UserID = @UserName

IF @UserSalt IS NULL
    EXEC csb.Login_GetRandomSalt @UserSalt OUTPUT

SELECT UserPasswordSalt = @UserSalt