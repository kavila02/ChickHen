
create proc FlockChecklist_DetailAlertSchedule_GetList
@FlockChecklist_DetailID int
,@IncludeNew bit = 1
As

declare @temp table (FlockChecklist_DetailAlertScheduleID int, RecipientsList nvarchar(500), flag bit)
insert into @temp select FlockChecklist_DetailAlertScheduleID, null, 0 from FlockChecklist_DetailAlertSchedule where FlockChecklist_DetailID = @FlockChecklist_DetailID
declare @currentID int
declare @recipients nvarchar(500)
while exists (select 1 from @temp where flag = 0)
begin
	select top 1 @currentID = FlockChecklist_DetailAlertScheduleID from @temp where flag = 0
	set @recipients = ''
	select @recipients = @recipients + case when @recipients = '' then '' else '; ' end
		+ IsNull(cr.RoleName,c.ContactName)
	from FlockChecklist_DetailAlertSchedule_Recipients r
		left outer join ContactRole cr on r.ContactRoleID = cr.ContactRoleID
		left outer join Contact c on c.ContactID = r.ContactID
	where FlockChecklist_DetailAlertScheduleID = @currentID
	update @temp set flag = 1, RecipientsList = @recipients where FlockChecklist_DetailAlertScheduleID = @currentID
end



select
	s.FlockChecklist_DetailAlertScheduleID
	, FlockChecklist_DetailID
	, AlertDescription
	, AlertTemplateID
	, TimeFromStep
	, TimeFromStep_DatePartID
	, convert(smallint,1) as SortOrder1
	, case when TimeFromStep_DatePartID = 'dd' then 1
			when TimeFromStep_DatePartID = 'wk' then 7
			when TimeFromStep_DatePartID = 'mm' then 30
			when TimeFromStep_DatePartID = 'yyyy' then 365
			else 0 end
			* IsNull(TimeFromStep,0) As SortOrder2
	, case when t.RecipientsList = '' then '{add}' else t.RecipientsList end as RecipientsList
	, StartDateOrEndDate
from FlockChecklist_DetailAlertSchedule s
	left outer join @temp t on s.FlockChecklist_DetailAlertScheduleID = t.FlockChecklist_DetailAlertScheduleID
where @FlockChecklist_DetailID = FlockChecklist_DetailID
union all
select
	FlockChecklist_DetailAlertScheduleID = convert(int,0)
	, FlockChecklist_DetailID = @FlockChecklist_DetailID
	, AlertDescription = convert(nvarchar(255),null)
	, AlertTemplateID = convert(int,null)
	, TimeFromStep = convert(int,null)
	, TimeFromStep_DatePartID = convert(varchar(4),null)
	, convert(smallint,2) As SortOrder1
	, convert(smallint,1) As SortOrder2
	, '{add}' As RecipientsList
	, convert(smallint,1) as StartDateOrEndDate
where @IncludeNew = 1
Order by SortOrder1, SortOrder2