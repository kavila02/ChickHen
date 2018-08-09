if not exists (select 1 from sys.tables where name = 'FlockChecklist')
begin
create table FlockChecklist
(
	FlockChecklistID int primary key identity(1,1)
	,FlockID int foreign key references Flock(FlockID)
	,ChecklistTemplateID int foreign key references ChecklistTemplate(ChecklistTemplateID)
	,FlockChecklistName nvarchar(255) --defaults to TemplateName but can be updated
)

create nonclustered index IX_FlockChecklist_FlockID
on FlockChecklist(FlockID)
create nonclustered index IX_FlockChecklist_ChecklistTemplateID
on FlockChecklist(ChecklistTemplateID)
end

