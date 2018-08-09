If not exists (select 1 from sys.tables where name = 'Files')
Begin
	create table Files
	(
		FileID int primary key identity(1,1)
		,FullName varchar(900)
		,Name varchar(250)
		,FolderID int --foreign key references Folders(FolderID)
	)
	create nonclustered index IX_Files_FolderID
	on Files(FolderID)
	create nonclustered index IX_Files_FullName
	on Files(FullName)
End