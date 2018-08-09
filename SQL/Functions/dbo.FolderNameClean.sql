create FUNCTION FolderNameClean (
	@string varchar(1000)
)
RETURNS varchar(1000)
AS
BEGIN
	RETURN (
	select replace(replace(replace(replace(replace(replace(replace(rtrim(@string),'/',''),'\',''),'*',''),'?',''),'<',''),'>',''),'|','')
	)
END