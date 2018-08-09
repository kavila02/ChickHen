



create proc [dbo].[PulletMover_Get]
@PulletMoverID int = null
,@IncludeNew bit = 1
As

select
	PulletMoverID
	, PulletMover
	, SortOrder
	, IsActive
from PulletMover
where IsNull(@PulletMoverID,PulletMoverID) = PulletMoverID
union all
select
	PulletMoverID = convert(int,0)
	, PulletMover = convert(nvarchar(255),null)
	, SortOrder = convert(int,IsNull((Select MAX(SortOrder) + 1 from PulletMover),1))
	, IsActive = convert(bit,null)
where @IncludeNew = 1
Order by SortOrder