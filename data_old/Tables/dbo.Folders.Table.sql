If not exists (select 1 from sys.tables where name = 'Folders')
Begin
	create table Folders
	(
		FolderID int primary key identity(1,1)
		,FullName varchar(900)
		,Name varchar(250)
		,ParentFolderID int
	)
	create nonclustered index IX_Folders_ParentFolderID
	on Folders(ParentFolderID)
	create nonclustered index IX_Folders_FullName
	on Folders(FullName)
End