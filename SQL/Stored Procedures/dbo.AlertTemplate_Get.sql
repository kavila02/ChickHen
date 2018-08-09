create proc dbo.AlertTemplate_Get
	@AlertTemplateID int
AS

select
	AlertTemplateID
	,AlertName
	,alertBody
	,alertSubject
	,SortOrder
	,IsActive
from AlertTemplate
where @AlertTemplateID = AlertTemplateID