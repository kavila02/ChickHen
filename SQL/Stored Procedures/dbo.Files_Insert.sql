create proc Files_Insert
	@FullName varchar(900)
	,@Name varchar(250)
	,@FolderID int
AS
	if not exists (select 1 from Files where FullName = @FullName)
		insert into Files (FullName, Name, FolderID)
		select @FullName, @Name, @FolderID