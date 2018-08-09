if not exists (select 1 from sys.tables where name = 'ChecklistTemplate')
begin
create table ChecklistTemplate
(
	ChecklistTemplateID int primary key identity(1,1)
	,TemplateName nvarchar(255)
)
end