
CREATE proc [dbo].[Flock_Delete]
@FlockID int
AS


declare @FlockChecklistID int
select @FlockChecklistID = FlockChecklistID from FlockChecklist where FlockID = @FlockID
exec FlockChecklist_Delete @FlockChecklistID = @FlockChecklistID

delete from FlockContact where FlockID = @FlockID
delete from FlockPulletGrower where FlockID = @FlockID
delete from FlockVaccine where FlockID = @FlockID
delete from FlockAttachment where FlockID = @FlockID
declare @attachment table (attachmentID int)
insert into @attachment
select AttachmentID from FlockAttachment where FlockID = @FlockID
delete from FlockAttachment where FlockID = @FlockID

declare @currentAttachmentID int
while exists (select 1 from @attachment)
begin
	select @currentAttachmentID = attachmentID from @attachment
	exec Attachment_Delete @AttachmentID = @currentAttachmentID
	delete from @attachment where attachmentID = @currentAttachmentID
end

delete from Flock where FlockID = @FlockID