
CREATE PROC [csb].[Login_AuthenticateUser]
    @UserName varchar(255)
    , @HashedPassword varchar(64)
AS

SELECT IsAuthenticated = CONVERT(bit, CASE WHEN EXISTS (
    SELECT TOP 1 UserPasswordSalt 
    FROM csb.UserTable u
    INNER JOIN csb.UserLoginTable l ON u.UserTableID = l.UserTableID
    WHERE u.UserID = @UserName AND l.UserPassword = @HashedPassword
) THEN 1 ELSE 0 END)