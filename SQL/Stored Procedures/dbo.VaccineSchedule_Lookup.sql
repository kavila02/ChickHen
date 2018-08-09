create proc VaccineSchedule_Lookup
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select VaccineSchedule,VaccineScheduleID,SortOrder
from VaccineSchedule
where IsActive = 1

union all
select '','',0
where @IncludeBlank = 1

Order by SortOrder