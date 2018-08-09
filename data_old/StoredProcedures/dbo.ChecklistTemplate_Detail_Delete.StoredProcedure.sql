if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_Detail_Delete' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_Detail_Delete
end
GO

create proc ChecklistTemplate_Detail_Delete
	@I_vChecklistTemplate_DetailID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

update FlockChecklist_DetailAlertSchedule set ChecklistTemplate_DetailAlertScheduleID = null
	where ChecklistTemplate_DetailAlertScheduleID in 
	(select ChecklistTemplate_DetailAlertScheduleID from ChecklistTemplate_DetailAlertSchedule where ChecklistTemplate_DetailID = @I_vChecklistTemplate_DetailID)
update FlockChecklist_Detail set ChecklistTemplate_DetailID = null where ChecklistTemplate_DetailID = @I_vChecklistTemplate_DetailID

delete from ChecklistTemplate_DetailAlertSchedule_Recipients where ChecklistTemplate_DetailAlertScheduleID in
	(select ChecklistTemplate_DetailAlertScheduleID from ChecklistTemplate_DetailAlertSchedule where ChecklistTemplate_DetailID in
		(select ChecklistTemplate_DetailID from ChecklistTemplate_Detail where ChecklistTemplate_DetailID = @I_vChecklistTemplate_DetailID))
delete from ChecklistTemplate_DetailAlertSchedule where ChecklistTemplate_DetailID in
		(select ChecklistTemplate_DetailID from ChecklistTemplate_Detail where ChecklistTemplate_DetailID = @I_vChecklistTemplate_DetailID)
declare @attachment table (attachmentID int)
insert into @attachment
select AttachmentID from ChecklistTemplate_DetailAttachment where ChecklistTemplate_DetailID in
	(select ChecklistTemplate_DetailID from ChecklistTemplate_Detail where ChecklistTemplate_DetailID = @I_vChecklistTemplate_DetailID)
delete from ChecklistTemplate_DetailAttachment where ChecklistTemplate_DetailID in
		(select ChecklistTemplate_DetailID from ChecklistTemplate_Detail where ChecklistTemplate_DetailID = @I_vChecklistTemplate_DetailID)

declare @currentAttachmentID int
while exists (select 1 from @attachment)
begin
	select @currentAttachmentID = attachmentID from @attachment
	exec Attachment_Delete @AttachmentID = @currentAttachmentID
	delete from @attachment where attachmentID = @currentAttachmentID
end

delete from ChecklistTemplate_Detail where ChecklistTemplate_DetailID = @I_vChecklistTemplate_DetailID