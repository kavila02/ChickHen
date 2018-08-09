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