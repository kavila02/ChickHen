if not exists (select 1 from sys.tables where name = 'ChecklistTemplate_DetailAlertSchedule')
begin
create table ChecklistTemplate_DetailAlertSchedule
(
	ChecklistTemplate_DetailAlertScheduleID int primary key identity(1,1)
	,ChecklistTemplate_DetailID int foreign key references ChecklistTemplate_Detail(ChecklistTemplate_DetailID)
	,AlertDescription nvarchar(255)

	--What to send
	,AlertTemplateID int foreign key references AlertTemplate(AlertTemplateID)

	--When to send
	,TimeFromStep int
	,TimeFromStep_DatePartID varchar(4) --store the sql datepart codes for these. ex: day = d, week = wk etc. (exec DatePart_Lookup)
	
	,StartDateOrEndDate smallint --1=start date, 2=end date
)
end
if not exists (Select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'ChecklistTemplate_DetailAlertSchedule' and c.name = 'StartDateOrEndDate')
begin
	alter table ChecklistTemplate_DetailAlertSchedule add StartDateOrEndDate smallint --1=start date, 2=end date
end