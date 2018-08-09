if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Folders_Insert' and s.name = 'dbo')
begin
	drop proc Folders_Insert
end
GO
create proc Folders_Insert
	@FullName varchar(900)
	,@Name varchar(250)
	,@ParentFolderID int
AS
	declare @folderID int
	if not exists (select 1 from Folders where FullName = @FullName)
	begin
		declare @folder table (folderID int)
		insert into Folders (FullName, Name, ParentFolderID)
		output inserted.folderID into @folder(folderID)
		select @FullName, @Name, @ParentFolderID

		select @folderID = folderID from @folder
	end
	else
	begin
		select @folderID = folderID from Folders where FullName = @FullName
	end

return @folderID