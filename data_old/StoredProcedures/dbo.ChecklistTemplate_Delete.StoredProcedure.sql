if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_Delete' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_Delete
end
GO
create proc ChecklistTemplate_Delete
@ChecklistTemplateID int
AS

update FlockChecklist_DetailAlertSchedule set ChecklistTemplate_DetailAlertScheduleID = null
	where ChecklistTemplate_DetailAlertScheduleID in 
	(select ChecklistTemplate_DetailAlertScheduleID from ChecklistTemplate_DetailAlertSchedule where ChecklistTemplate_DetailID in
		(select ChecklistTemplate_DetailID from ChecklistTemplate_Detail where ChecklistTemplateID = @ChecklistTemplateID))
update FlockChecklist_Detail set ChecklistTemplate_DetailID = null where ChecklistTemplate_DetailID in
		(select ChecklistTemplate_DetailID from ChecklistTemplate_Detail where ChecklistTemplateID = @ChecklistTemplateID)
update FlockChecklist set ChecklistTemplateID = null where ChecklistTemplateID = @ChecklistTemplateID

delete from ChecklistTemplate_DetailAlertSchedule_Recipients where ChecklistTemplate_DetailAlertScheduleID in
	(select ChecklistTemplate_DetailAlertScheduleID from ChecklistTemplate_DetailAlertSchedule where ChecklistTemplate_DetailID in
		(select ChecklistTemplate_DetailID from ChecklistTemplate_Detail where ChecklistTemplateID in
			(select ChecklistTemplateID from ChecklistTemplate where ChecklistTemplateID = @ChecklistTemplateID)))
delete from ChecklistTemplate_DetailAlertSchedule where ChecklistTemplate_DetailID in
		(select ChecklistTemplate_DetailID from ChecklistTemplate_Detail where ChecklistTemplateID in
			(select ChecklistTemplateID from ChecklistTemplate where ChecklistTemplateID = @ChecklistTemplateID))
declare @attachment table (attachmentID int)
insert into @attachment
select AttachmentID from ChecklistTemplate_DetailAttachment where ChecklistTemplate_DetailID in
	(select ChecklistTemplate_DetailID from ChecklistTemplate_Detail where ChecklistTemplateID in
			(select ChecklistTemplateID from ChecklistTemplate where ChecklistTemplateID = @ChecklistTemplateID))
delete from ChecklistTemplate_DetailAttachment where ChecklistTemplate_DetailID in
		(select ChecklistTemplate_DetailID from ChecklistTemplate_Detail where ChecklistTemplateID in
			(select ChecklistTemplateID from ChecklistTemplate where ChecklistTemplateID = @ChecklistTemplateID))

declare @currentAttachmentID int
while exists (select 1 from @attachment)
begin
	select @currentAttachmentID = attachmentID from @attachment
	exec Attachment_Delete @AttachmentID = @currentAttachmentID
	delete from @attachment where attachmentID = @currentAttachmentID
end


delete from ChecklistTemplate_Detail_Vaccine where ChecklistTemplate_DetailID in
	(select ChecklistTemplate_DetailID from ChecklistTemplate_Detail where ChecklistTemplateID in
		(select ChecklistTemplateID from ChecklistTemplate where ChecklistTemplateID = @ChecklistTemplateID))


delete from ChecklistTemplate_Detail where ChecklistTemplateID in
	(select ChecklistTemplateID from ChecklistTemplate where ChecklistTemplateID = @ChecklistTemplateID)
delete from ChecklistTemplate where ChecklistTemplateID = @ChecklistTemplateID
