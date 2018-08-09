if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Files_Insert' and s.name = 'dbo')
begin
	drop proc Files_Insert
end
GO
create proc Files_Insert
	@FullName varchar(900)
	,@Name varchar(250)
	,@FolderID int
AS
	if not exists (select 1 from Files where FullName = @FullName)
		insert into Files (FullName, Name, FolderID)
		select @FullName, @Name, @FolderID