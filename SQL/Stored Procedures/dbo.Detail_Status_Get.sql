create proc [dbo].[Detail_Status_Get]
@Detail_StatusID int = null
,@IncludeNew bit = 1
As

select
	Detail_StatusID
	, Detail_Status
	, SortOrder
	, IsActive
from Detail_Status
where IsNull(@Detail_StatusID,Detail_StatusID) = Detail_StatusID
union all
select
	Detail_StatusID = convert(int,0)
	, Detail_Status = convert(nvarchar(255),null)
	, SortOrder = convert(int,IsNull((Select MAX(SortOrder) + 1 from Detail_Status),1))
	, IsActive = convert(bit,null)
where @IncludeNew = 1
Order by SortOrder