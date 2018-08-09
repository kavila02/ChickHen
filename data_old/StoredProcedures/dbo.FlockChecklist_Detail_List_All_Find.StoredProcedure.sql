if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockChecklist_Detail_List_All_Find' and s.name = 'dbo')
begin
	drop proc FlockChecklist_Detail_List_All_Find
end
GO
create proc FlockChecklist_Detail_List_All_Find
As

select
	convert(int,null) as FlockID
	,convert(int,null) as ChecklistTemplateID
	,convert(int,null) as Detail_StatusID