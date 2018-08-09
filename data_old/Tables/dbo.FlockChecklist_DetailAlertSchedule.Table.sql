if not exists (select 1 from sys.tables where name = 'FlockChecklist_DetailAlertSchedule')
begin
create table FlockChecklist_DetailAlertSchedule
(
	FlockChecklist_DetailAlertScheduleID int primary key identity(1,1)
	,FlockChecklist_DetailID int foreign key references FlockChecklist_Detail(FlockChecklist_DetailID)
	,AlertDescription nvarchar(255)

	--What to send
	,AlertTemplateID int foreign key references AlertTemplate(AlertTemplateID)

	--When to send
	,TimeFromStep int
	,TimeFromStep_DatePartID varchar(4) --store the sql datepart codes for these. ex: day = d, week = wk etc. (exec DatePart_Lookup)
	
	,AlertSent bit
	,ChecklistTemplate_DetailAlertScheduleID int foreign key references ChecklistTemplate_DetailAlertSchedule(ChecklistTemplate_DetailAlertScheduleID)

	,StartDateOrEndDate smallint --1=start date, 2=end date
)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockChecklist_DetailAlertSchedule' and c.name='AlertSent')
begin
	alter table FlockChecklist_DetailAlertSchedule add AlertSent bit
end


if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockChecklist_DetailAlertSchedule' and c.name='ChecklistTemplate_DetailAlertScheduleID')
begin
	alter table FlockChecklist_DetailAlertSchedule add ChecklistTemplate_DetailAlertScheduleID int foreign key references ChecklistTemplate_DetailAlertSchedule(ChecklistTemplate_DetailAlertScheduleID)
end

if not exists (Select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FlockChecklist_DetailAlertSchedule' and c.name = 'StartDateOrEndDate')
begin
	alter table FlockChecklist_DetailAlertSchedule add StartDateOrEndDate smallint --1=start date, 2=end date
end