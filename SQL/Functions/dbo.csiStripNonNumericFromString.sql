
create FUNCTION dbo.csiStripNonNumericFromString (
	 @string varchar(255)
) 
RETURNS varchar(255) 
AS 
BEGIN 
	DECLARE @outputstring varchar(255) 
	SET @outputstring = @string 

	DECLARE @pos int 
	SET @pos = PATINDEX('%[^0-9]%', @outputstring) 

	WHILE (@pos > 0) 
	BEGIN 
		SET @outputstring = STUFF(@outputstring, @pos, 1, '') 
		SET @pos = PATINDEX('%[^0-9]%', @outputstring) 
	END 

	RETURN @outputstring 
END