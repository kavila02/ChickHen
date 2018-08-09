
CREATE PROC [csb].[Login_GetRandomSalt]
    @Output varchar(32) OUTPUT
AS

SELECT @Output = ''

DECLARE @Length int = 32

WHILE @Length > 0
BEGIN
    SELECT 
	   @Output += REPLACE(CHAR(ROUND(RAND() * 74 + 48, 0)), '>', '_')
	   , @Length -= 1
END