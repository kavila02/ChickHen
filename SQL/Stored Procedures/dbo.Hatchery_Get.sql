create proc Hatchery_Get
@HatcheryID int = null
,@IncludeNew bit = 1
As

select
	HatcheryID
	, Hatchery
	, SortOrder
	, IsActive
from Hatchery
where IsNull(@HatcheryID,HatcheryID) = HatcheryID
union all
select
	HatcheryID = convert(int,0)
	, Hatchery = convert(nvarchar(255),null)
	, SortOrder = convert(int,IsNull((Select MAX(SortOrder) + 1 from Hatchery),1))
	, IsActive = convert(bit,1)
where @IncludeNew = 1
Order by SortOrder