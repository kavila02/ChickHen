if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockChecklist_Detail_Delete' and s.name = 'dbo')
begin
	drop proc FlockChecklist_Detail_Delete
end
GO

create proc FlockChecklist_Detail_Delete
	@I_vFlockChecklist_DetailID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

delete from FlockChecklist_DetailAlertSchedule_Recipients where FlockChecklist_DetailAlertScheduleID in
	(select FlockChecklist_DetailAlertScheduleID from FlockChecklist_DetailAlertSchedule where FlockChecklist_DetailID in
		(select FlockChecklist_DetailID from FlockChecklist_Detail where FlockChecklist_DetailID = @I_vFlockChecklist_DetailID))
delete from FlockChecklist_DetailAlertSchedule where FlockChecklist_DetailID in
		(select FlockChecklist_DetailID from FlockChecklist_Detail where FlockChecklist_DetailID = @I_vFlockChecklist_DetailID)
declare @attachment table (attachmentID int)
insert into @attachment
select AttachmentID from FlockChecklist_DetailAttachment where FlockChecklist_DetailID in
	(select FlockChecklist_DetailID from FlockChecklist_Detail where FlockChecklist_DetailID = @I_vFlockChecklist_DetailID)
delete from FlockChecklist_DetailAttachment where FlockChecklist_DetailID in
		(select FlockChecklist_DetailID from FlockChecklist_Detail where FlockChecklist_DetailID = @I_vFlockChecklist_DetailID)

declare @currentAttachmentID int
while exists (select 1 from @attachment)
begin
	select @currentAttachmentID = attachmentID from @attachment
	exec Attachment_Delete @AttachmentID = @currentAttachmentID
	delete from @attachment where attachmentID = @currentAttachmentID
end


delete from FlockChecklist_Detail where FlockChecklist_DetailID = @I_vFlockChecklist_DetailID