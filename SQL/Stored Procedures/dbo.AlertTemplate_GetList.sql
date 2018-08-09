create proc dbo.AlertTemplate_GetList
AS

select
	AlertTemplateID
	,AlertName
	,SortOrder
	,IsActive
from AlertTemplate
order by IsActive desc, SortOrder