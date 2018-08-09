﻿
CREATE proc [dbo].[ChecklistTemplate_DetailAlertSchedule_GetList]
@ChecklistTemplate_DetailID int
,@IncludeNew bit = 1
As

declare @temp table (ChecklistTemplate_DetailAlertScheduleID int, RecipientsList nvarchar(500), flag bit)
insert into @temp select ChecklistTemplate_DetailAlertScheduleID, null, 0 from ChecklistTemplate_DetailAlertSchedule where CheckListTemplate_DetailID = @ChecklistTemplate_DetailID
declare @currentID int
declare @recipients nvarchar(500)
while exists (select 1 from @temp where flag = 0)
begin
	select top 1 @currentID = ChecklistTemplate_DetailAlertScheduleID from @temp where flag = 0
	set @recipients = ''
	select @recipients = @recipients + case when @recipients = '' then '' else '; ' end
		+ IsNull(cr.RoleName,c.ContactName)
	from ChecklistTemplate_DetailAlertSchedule_Recipients r
		left outer join ContactRole cr on r.ContactRoleID = cr.ContactRoleID
		left outer join Contact c on c.ContactID = r.ContactID
	where ChecklistTemplate_DetailAlertScheduleID = @currentID
	update @temp set flag = 1, RecipientsList = @recipients where ChecklistTemplate_DetailAlertScheduleID = @currentID
end



select
	s.ChecklistTemplate_DetailAlertScheduleID
	, ChecklistTemplate_DetailID
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
from ChecklistTemplate_DetailAlertSchedule s
	left outer join @temp t on s.ChecklistTemplate_DetailAlertScheduleID = t.ChecklistTemplate_DetailAlertScheduleID
where @ChecklistTemplate_DetailID = ChecklistTemplate_DetailID
union all
select
	ChecklistTemplate_DetailAlertScheduleID = convert(int,0)
	, ChecklistTemplate_DetailID = @ChecklistTemplate_DetailID
	, AlertDescription = convert(nvarchar(255),null)
	, AlertTemplateID = convert(int,null)
	, TimeFromStep = convert(int,null)
	, TimeFromStep_DatePartID = convert(varchar(4),null)
	, convert(smallint,2) As SortOrder1
	, convert(smallint,1) As SortOrder2
	, null As RecipientsList
	, convert(smallint,1) as StartDateOrEndDate
where @IncludeNew = 1
Order by SortOrder1, SortOrder2