
create proc [dbo].[FlockChecklist_DetailAlertSchedule_Recipients_GetList]
@FlockChecklist_DetailAlertScheduleID int
,@IncludeNew smallint = 3
As

declare @results table (
	FlockChecklist_DetailAlertSchedule_RecipientsID int
	, FlockChecklist_DetailAlertScheduleID int
	, RecipientType smallint
	, ContactRoleID int
	, ContactID int
)

insert into @results
select
	FlockChecklist_DetailAlertSchedule_RecipientsID
	, FlockChecklist_DetailAlertScheduleID
	, RecipientType
	, ContactRoleID
	, ContactID
from FlockChecklist_DetailAlertSchedule_Recipients
where FlockChecklist_DetailAlertScheduleID = @FlockChecklist_DetailAlertScheduleID

declare @loop int = 1
while @IncludeNew >= @loop
begin
	insert into @results
	select
		FlockChecklist_DetailAlertSchedule_RecipientsID = convert(int,0)
		, FlockChecklist_DetailAlertScheduleID = @FlockChecklist_DetailAlertScheduleID
		, RecipientType = convert(smallint,1)
		, ContactRoleID = convert(int,null)
		, ContactID = convert(int,null)
	
	select @loop = @loop + 1
end

Select * from @results
Order by RecipientType