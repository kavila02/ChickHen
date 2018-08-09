if exists (select 1 from sys.objects f inner join sys.schemas s on f.schema_id = s.schema_id where f.type = 'FN' and f.name = 'FolderNameClean' and s.name = 'dbo')
begin
	drop function FolderNameClean
end
GO
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


