if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'DeleteMajorObject_Get' and s.name = 'dbo')
begin
	drop proc DeleteMajorObject_Get
end
GO
create proc DeleteMajorObject_Get
AS

select
	'' As EntityID
	,0 As FlockID
	,0 As FlockChecklistID
	,0 As ChecklistTemplateID
	,'<span style="font-size:large;color:red;font-weight:bold">Warning- this will delete entire Flock and all associated attachments and information</span>' As FlockWarningMessage
	,'<span style="font-size:large;color:red;font-weight:bold">Warning- this will delete entire Flock''s Checklist and all associated attachments, steps, and information</span>' As FlockChecklistWarningMessage
	,'<span style="font-size:large;color:red;font-weight:bold">Warning- this will delete entire Template and all associated attachments and information</span>' As ChecklistTemplateWarningMessage
	,convert(bit,1) As ShowDelete