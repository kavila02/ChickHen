if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FilesAndFolder_TreeviewWrapper' and s.name = 'dbo')
begin
	drop proc FilesAndFolder_TreeviewWrapper
end
GO
create proc FilesAndFolder_TreeviewWrapper
	@FolderID int
AS

create table #TreeViewResults (rowID varchar(50), parentID varchar(50), displayValue varchar(250), linkValue varchar(20), screenValue varchar(100), sort int, className varchar(50), saveValue varchar(900), isFolder bit)

exec FilesAndFolder_Treeview @FolderID = @FolderID, @isFirst = 1

update tvr
set className='fileExists'
from #TreeViewResults tvr
inner join Attachment a on tvr.saveValue = a.Path


select * from #TreeViewResults
drop table #TreeViewResults
