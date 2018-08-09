if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Checklist_DetailType_Get' and s.name = 'dbo')
begin
	drop proc Checklist_DetailType_Get
end
GO
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