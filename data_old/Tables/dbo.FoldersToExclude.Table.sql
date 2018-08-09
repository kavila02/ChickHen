if not exists (select 1 from sys.tables where name = 'FoldersToExclude')
begin
	create table FoldersToExclude
	(
		FoldersToExcludeID int primary key identity(1,1)
		,FullName nvarchar(2000)
	)
end

go