create proc Checklist_DetailType_Lookup
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select Checklist_DetailType,Checklist_DetailTypeID,SortOrder
from Checklist_DetailType
where Active = 1

union all
select '','',0
where @IncludeBlank = 1

union all
select 'All','',0
where @IncludeAll = 1

Order by SortOrder