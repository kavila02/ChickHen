create proc VaccineSchedule_Get
@VaccineScheduleID int = null
,@IncludeNew bit = 1
As

select
	VaccineScheduleID
	, VaccineSchedule
	, SortOrder
	, IsActive
from VaccineSchedule
where IsNull(@VaccineScheduleID,VaccineScheduleID) = VaccineScheduleID
union all
select
	VaccineScheduleID = convert(int,0)
	, VaccineSchedule = convert(nvarchar(255),null)
	, SortOrder = convert(int,IsNull((Select MAX(SortOrder) + 1 from VaccineSchedule),1))
	, IsActive = convert(bit,1)
where @IncludeNew = 1
Order by SortOrder