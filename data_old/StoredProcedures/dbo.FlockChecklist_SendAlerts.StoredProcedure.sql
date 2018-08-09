if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockChecklist_SendAlerts' and s.name = 'dbo')
begin
	drop proc FlockChecklist_SendAlerts
end
GO
create proc FlockChecklist_SendAlerts
	@I_valertDate date
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

create table #ScheduledAlerts (FlockChecklist_DetailAlertScheduleID int, recipientsTo nvarchar(500), recipientsCC nvarchar(500), recipientsBCC nvarchar(500), processed bit)

--thought about dynamic sql here, but this seemed to work in my brain better
insert into #ScheduledAlerts (FlockChecklist_DetailAlertScheduleID, recipientsTo, recipientsCC, recipientsBCC, processed)
select FlockChecklist_DetailAlertScheduleID, null, null, null, 0
from FlockChecklist_DetailAlertSchedule s
inner join FlockChecklist_Detail d on s.FlockChecklist_DetailID = d.FlockChecklist_DetailID
where case when s.TimeFromStep_DatePartID = 'dd' then DATEADD(dd,s.TimeFromStep,d.DateOfAction)
			when s.TimeFromStep_DatePartID = 'wk' then DATEADD(wk,s.TimeFromStep,d.DateOfAction)
			when s.TimeFromStep_DatePartID = 'mm' then DATEADD(mm,s.TimeFromStep,d.DateOfAction)
			when s.TimeFromStep_DatePartID = 'yyyy' then DATEADD(yyyy,s.TimeFromStep,d.DateOfAction)
			else null end = @I_valertDate
and s.AlertSent = 0

declare @currentRecipTo nvarchar(500), @currentRecipCC nvarchar(500), @currentRecipBCC nvarchar(500), @currentID int
while exists (select 1 from #ScheduledAlerts where processed = 0)
begin
	select top 1 @currentID = FlockChecklist_DetailAlertScheduleID, @currentRecipTo = '', @currentRecipCC = '', @currentRecipBCC = '' from #ScheduledAlerts

	select @currentRecipTo = @currentRecipTo + case when r.RecipientType = 1 then
									case when @currentRecipTo = '' then '' else ';' end
									+ IsNull(c.PrimaryEmailAddress,'')
								else '' end
		,@currentRecipCC = @currentRecipCC + case when r.RecipientType = 2 then
									case when @currentRecipCC = '' then '' else ';' end
									+ IsNull(c.PrimaryEmailAddress,'')
								else '' end
		,@currentRecipBCC = @currentRecipBCC + case when r.RecipientType = 3 then
									case when @currentRecipBCC = '' then '' else ';' end
									+ IsNull(c.PrimaryEmailAddress,'')
								else '' end
	from FlockChecklist_DetailAlertSchedule_Recipients r
		inner join Contact c on r.ContactID = c.ContactID
	where r.FlockChecklist_DetailAlertScheduleID = @currentID

	select @currentRecipTo = @currentRecipTo + case when r.RecipientType = 1 then
									case when @currentRecipTo = '' then '' else ';' end
									+ IsNull(c.PrimaryEmailAddress,'')
								else '' end
		,@currentRecipCC = @currentRecipCC + case when r.RecipientType = 2 then
									case when @currentRecipCC = '' then '' else ';' end
									+ IsNull(c.PrimaryEmailAddress,'')
								else '' end
		,@currentRecipBCC = @currentRecipBCC + case when r.RecipientType = 3 then
									case when @currentRecipBCC = '' then '' else ';' end
									+ IsNull(c.PrimaryEmailAddress,'')
								else '' end
	from FlockChecklist_DetailAlertSchedule_Recipients r
		inner join FlockChecklist_DetailAlertSchedule s on r.FlockChecklist_DetailAlertScheduleID = s.FlockChecklist_DetailAlertScheduleID
		inner join FlockChecklist_Detail d on s.FlockChecklist_DetailID = d.FlockChecklist_DetailID
		inner join FlockChecklist fc on d.FlockChecklistID = fc.FlockChecklistID
		inner join Flock f on fc.FlockID = f.FlockID
		inner join FlockContact fcon on f.FlockID = fcon.FlockID and r.ContactRoleID = fcon.ContactRoleID
		inner join Contact c on fcon.ContactID = c.ContactID
	where r.FlockChecklist_DetailAlertScheduleID = @currentID

	update #ScheduledAlerts set recipientsTo = @currentRecipTo, recipientsCC = @currentRecipCC, recipientsBCC = @currentRecipBCC, Processed = 1 where FlockChecklist_DetailAlertScheduleID = @currentID
end

insert into MessageQueue (MessageContent, FromEmail, ToEmail, CcEmail, BccEmail, Processed, Subject)
select
	MessageContent = dbo.FlockChecklist_DetailAlertSchedule_FormatAlert(t.alertBody,sa.FlockChecklist_DetailAlertScheduleID)
	, FromEmail = 'koopalerts@kreiderfarms.com'
	, ToEmail = sa.recipientsTo
	, CcEmail = sa.recipientsCC
	, BccEmail = sa.recipientsBCC
	, Processed = 0
	, Subject = rtrim(m.SubjectPrefix) + dbo.FlockChecklist_DetailAlertSchedule_FormatAlert(t.alertSubject,sa.FlockChecklist_DetailAlertScheduleID)
from #ScheduledAlerts sa
		inner join FlockChecklist_DetailAlertSchedule s on sa.FlockChecklist_DetailAlertScheduleID = s.FlockChecklist_DetailAlertScheduleID
		inner join AlertTemplate t on s.AlertTemplateID = t.AlertTemplateID
		cross join Message_DefaultValues m

update s
set s.AlertSent = 1
from FlockChecklist_DetailAlertSchedule s
inner join #ScheduledAlerts sa on sa.FlockChecklist_DetailAlertScheduleID = s.FlockChecklist_DetailAlertScheduleID