
create proc [dbo].[AlertTemplate_Lookup]
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select AlertName, AlertTemplateID, SortOrder
from AlertTemplate
where IsActive = 1

union all
select '','',0
where @IncludeBlank = 1

Order by SortOrder