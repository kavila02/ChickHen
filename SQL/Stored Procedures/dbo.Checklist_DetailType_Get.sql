create proc Checklist_DetailType_Get
@Checklist_DetailTypeID int = null
,@IncludeNew bit = 1
As

select
	Checklist_DetailTypeID
	, Checklist_DetailType
	, SortOrder
	, Active
from Checklist_DetailType
where IsNull(@Checklist_DetailTypeID,Checklist_DetailTypeID) = Checklist_DetailTypeID
union all
select
	Checklist_DetailTypeID = convert(int,0)
	, Checklist_DetailType = convert(nvarchar(255),null)
	, SortOrder = convert(int,IsNull((Select MAX(SortOrder) + 1 from Checklist_DetailType),1))
	, Active = convert(bit,1)
where @IncludeNew = 1
Order by SortOrder