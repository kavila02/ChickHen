if not exists (select 1 from sys.tables where name = 'ChecklistTemplate_Detail')
begin
create table ChecklistTemplate_Detail
(
	ChecklistTemplate_DetailID int primary key identity(1,1)
	,ChecklistTemplateID int foreign key references ChecklistTemplate(ChecklistTemplateID)
	,StepName nvarchar(255)
	,StepOrder int
	,ActionDescription nvarchar(500)

	--These are for calculating due dates
	,StepOrFieldCalculation smallint --1 FromStep, 2 FromField

	,DateOfAction_TimeFromStep int
	,TimeFromStep_DatePartID varchar(4) --store the sql datepart codes for these. ex: day = d, week = wk etc. (exec DatePart_Lookup)
	,DateOfAction_FlockChecklist_DetailID int --foreign key references FlockChecklist_Detail(FlockChecklist_DetailID)

	,DateOfAction_TimeFromField int
	,TimeFromField_DatePartID varchar(4) --store the sql datepart codes for these. ex: day = d, week = wk etc. (exec DatePart_Lookup)
	,DateOfAction_FieldReferenceID int --foreign key references FieldReference(FieldReferenceID)
	---------------------------------------------------
	--These are for calculating due dates
	,StepOrFieldCalculation_EndDate smallint --1 FromStep, 2 FromField

	,DateOfAction_TimeFromStep_EndDate int
	,TimeFromStep_DatePartID_EndDate varchar(4) --store the sql datepart codes for these. ex: day = d, week = wk etc. (exec DatePart_Lookup)
	,DateOfAction_FlockChecklist_DetailID_EndDate int --foreign key references FlockChecklist_Detail(FlockChecklist_DetailID)

	,DateOfAction_TimeFromField_EndDate int
	,TimeFromField_DatePartID_EndDate varchar(4) --store the sql datepart codes for these. ex: day = d, week = wk etc. (exec DatePart_Lookup)
	,DateOfAction_FieldReferenceID_EndDate int --foreign key references FieldReference(FieldReferenceID)
	---------------------------------------------------

	,OriginatorID int foreign key references ContactRole(ContactRoleID)
	,DetailedNotes nvarchar(4000)

	--,CompletedByID int foreign key references Contact(ContactID)
	--,CompletedDate datetime

	,DefaultDetail_StatusID int foreign key references Detail_Status(Detail_StatusID)

	,Checklist_DetailTypeID int foreign key references Checklist_DetailType(Checklist_DetailTypeID)
)
create nonclustered index IX_ChecklistTemplate_Detail_ChecklistTemplateID
on ChecklistTemplate_Detail(ChecklistTemplateID)
end


if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'ChecklistTemplate_Detail' and c.Name='DefaultDetail_StatusID')
begin
	alter table ChecklistTemplate_Detail add DefaultDetail_StatusID int foreign key references Detail_Status(Detail_StatusID)
end

if not exists (select 1 from sys.indexes i inner join sys.tables t on i.object_id = t.object_id where t.name = 'ChecklistTemplate_Detail' and i.name='IX_ChecklistTemplate_Detail_StepOrder')
begin
	create nonclustered index IX_ChecklistTemplate_Detail_StepOrder
	on ChecklistTemplate_Detail(StepOrder)
end

if exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'ChecklistTemplate_Detail' and c.Name='CompletedByID')
begin
	declare @sql nvarchar(500)
	select @sql = 'alter table ChecklistTemplate_Detail drop constraint ' + rtrim(fk2.name)
	from sys.foreign_key_columns fk
				inner join sys.tables t on fk.parent_object_id = t.object_id and t.name = 'ChecklistTemplate_Detail'
				inner join sys.columns c on fk.parent_object_id = c.object_id and fk.parent_column_id = c.column_id and c.name = 'CompletedByID'
				inner join sys.tables t2 on fk.referenced_object_id = t2.object_id and t2.name = 'Contact'
				inner join sys.columns c2 on fk.referenced_object_id = c2.object_id and fk.referenced_column_id = c2.column_id and c2.name = 'ContactID'
				inner join sys.foreign_keys fk2 on fk.constraint_object_id = fk2.object_id
	exec (@sql)
	alter table ChecklistTemplate_Detail drop column CompletedByID
end

if exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'ChecklistTemplate_Detail' and c.Name='CompletedDate')
begin
	alter table ChecklistTemplate_Detail drop column CompletedDate
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'ChecklistTemplate_Detail' and c.Name='Checklist_DetailTypeID')
begin
	alter table ChecklistTemplate_Detail add Checklist_DetailTypeID int foreign key references Checklist_DetailType(Checklist_DetailTypeID)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'ChecklistTemplate_Detail' and c.Name='StepOrFieldCalculation_EndDate')
begin
	alter table ChecklistTemplate_Detail add StepOrFieldCalculation_EndDate smallint --1 FromStep, 2 FromField

	,DateOfAction_TimeFromStep_EndDate int
	,TimeFromStep_DatePartID_EndDate varchar(4) --store the sql datepart codes for these. ex: day = d, week = wk etc. (exec DatePart_Lookup)
	,DateOfAction_FlockChecklist_DetailID_EndDate int --foreign key references FlockChecklist_Detail(FlockChecklist_DetailID)

	,DateOfAction_TimeFromField_EndDate int
	,TimeFromField_DatePartID_EndDate varchar(4) --store the sql datepart codes for these. ex: day = d, week = wk etc. (exec DatePart_Lookup)
	,DateOfAction_FieldReferenceID_EndDate int --foreign key references FieldReference(FieldReferenceID)
end