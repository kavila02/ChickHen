if not exists (select 1 from sys.tables where name = 'FlockChecklist_Detail')
begin
create table FlockChecklist_Detail
(
	FlockChecklist_DetailID int primary key identity(1,1)
	,FlockChecklistID int foreign key references FlockChecklist(FlockChecklistID)
	,StepName nvarchar(255)
	,StepOrder int
	,ActionDescription nvarchar(500)
	,DateOfAction date --calculates on template creation
	--These are for reference with possible recalc options
	,StepOrFieldCalculation smallint --1 FromStep, 2 FromField

	,DateOfAction_TimeFromStep int
	,TimeFromStep_DatePartID varchar(4) --store the sql datepart codes for these. ex: day = d, week = wk etc. (exec DatePart_Lookup)
	,DateOfAction_FlockChecklist_DetailID int --foreign key references FlockChecklist_Detail(FlockChecklist_DetailID)

	,DateOfAction_TimeFromField int
	,TimeFromField_DatePartID varchar(4) --store the sql datepart codes for these. ex: day = d, week = wk etc. (exec DatePart_Lookup)
	,DateOfAction_FieldReferenceID int --foreign key references FieldReference(FieldReferenceID)
	---------------------------------------------------
	,DateOfAction_EndDate date --calculates on template creation
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
	
	,CompletedByID int foreign key references Contact(ContactID)
	,CompletedDate datetime

	,Detail_StatusID int foreign key references Detail_Status(Detail_StatusID)
	,ChecklistTemplate_DetailID int foreign key references ChecklistTemplate_Detail(ChecklistTemplate_DetailID)

	,Checklist_DetailTypeID int foreign key references Checklist_DetailType(Checklist_DetailTypeID)
)
create nonclustered index IX_FlockChecklist_Detail_FlockChecklistID
on FlockChecklist_Detail(FlockChecklistID)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockChecklist_Detail' and c.Name='Detail_StatusID')
begin
	alter table FlockChecklist_Detail add Detail_StatusID int foreign key references Detail_Status(Detail_StatusID)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockChecklist_Detail' and c.Name='ChecklistTemplate_DetailID')
begin
	alter table FlockChecklist_Detail add ChecklistTemplate_DetailID int foreign key references ChecklistTemplate_Detail(ChecklistTemplate_DetailID)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockChecklist_Detail' and c.Name='Checklist_DetailTypeID')
begin
	alter table FlockChecklist_Detail add Checklist_DetailTypeID int foreign key references Checklist_DetailType(Checklist_DetailTypeID)
end


if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockChecklist_Detail' and c.Name='StepOrFieldCalculation_EndDate')
begin
	alter table FlockChecklist_Detail add StepOrFieldCalculation_EndDate smallint --1 FromStep, 2 FromField

	,DateOfAction_TimeFromStep_EndDate int
	,TimeFromStep_DatePartID_EndDate varchar(4) --store the sql datepart codes for these. ex: day = d, week = wk etc. (exec DatePart_Lookup)
	,DateOfAction_FlockChecklist_DetailID_EndDate int --foreign key references FlockChecklist_Detail(FlockChecklist_DetailID)

	,DateOfAction_TimeFromField_EndDate int
	,TimeFromField_DatePartID_EndDate varchar(4) --store the sql datepart codes for these. ex: day = d, week = wk etc. (exec DatePart_Lookup)
	,DateOfAction_FieldReferenceID_EndDate int --foreign key references FieldReference(FieldReferenceID)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockChecklist_Detail' and c.Name='DateOfAction_EndDate')
begin
	alter table FlockChecklist_Detail add DateOfAction_EndDate date --calculates on template creation
end