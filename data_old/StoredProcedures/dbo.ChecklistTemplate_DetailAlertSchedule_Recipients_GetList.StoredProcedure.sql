if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_DetailAlertSchedule_Recipients_GetList' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_DetailAlertSchedule_Recipients_GetList
end
GO

create proc ChecklistTemplate_DetailAlertSchedule_Recipients_GetList
@ChecklistTemplate_DetailAlertScheduleID int
,@IncludeNew smallint = 3
As

declare @results table (
	ChecklistTemplate_DetailAlertSchedule_RecipientsID int
	, ChecklistTemplate_DetailAlertScheduleID int
	, RecipientType smallint
	, ContactRoleID int
	, ContactID int
)

insert into @results
select
	ChecklistTemplate_DetailAlertSchedule_RecipientsID
	, ChecklistTemplate_DetailAlertScheduleID
	, RecipientType
	, ContactRoleID
	, ContactID
from ChecklistTemplate_DetailAlertSchedule_Recipients
where ChecklistTemplate_DetailAlertScheduleID = @ChecklistTemplate_DetailAlertScheduleID

declare @loop int = 1
while @IncludeNew >= @loop
begin
	insert into @results
	select
		ChecklistTemplate_DetailAlertSchedule_RecipientsID = convert(int,0)
		, ChecklistTemplate_DetailAlertScheduleID = @ChecklistTemplate_DetailAlertScheduleID
		, RecipientType = convert(smallint,1)
		, ContactRoleID = convert(int,null)
		, ContactID = convert(int,null)
	
	select @loop = @loop + 1
end

Select * from @results
Order by RecipientType