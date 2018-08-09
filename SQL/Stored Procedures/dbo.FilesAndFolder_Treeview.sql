create proc FilesAndFolder_Treeview
	@FolderID int
	,@isFirst bit
AS

If exists (select 1 from Folders f inner join FoldersToExclude e on f.FullName = e.FullName where FolderID = @FolderID)
	return

--insert the current folder
insert into #TreeViewResults (rowID, parentID, displayValue, linkValue, screenValue, sort, className, saveValue, isFolder)
select
	rowID = 'Folder' + convert(varchar,FolderID)
	,parentID = case when @isFirst = 1 or ParentFolderID = 0 then null else 'Folder' + convert(varchar,ParentFolderID) end
	,displayValue = Name
	,linkValue = ''
	,screenValue = ''
	,sort = ''
	,className = ''
	,saveValue = FullName
	,isFolder = convert(bit,1)
from Folders
where FolderID = @FolderID
--and FullName not in (select FullName from FoldersToExclude)

--run this for all children folders to add them and their children
declare @kids table (FolderID int)
insert into @kids select FolderID from Folders where ParentFolderID = @FolderID
declare @currentKid int
while exists (select 1 from @kids)
begin
	select top 1 @currentKid = FolderID from @kids
	exec FilesAndFolder_Treeview @FolderID = @currentKid, @isFirst = 0
	delete from @kids where FolderID = @currentKid
end

--add all files for the current folder
insert into #TreeViewResults (rowID, parentID, displayValue, linkValue, screenValue, sort, className, saveValue, isFolder)
select
	rowID = 'File' + convert(varchar,FileID)
	,parentID = case when @isFirst = 1 or FolderID = 0 then null else 'Folder' + convert(varchar,FolderID) end
	,displayValue = Name
	,linkValue = ''
	,screenValue = ''
	,sort = ''
	,className = ''
	,saveValue = FullName
	,isFolder = convert(bit,0)
from Files
where FolderID = @FolderID

--select * from #TreeViewResults