create proc VaccineScheduleVaccine_Get
@VaccineScheduleID int = null
,@IncludeNew bit = 1
As

select
	VaccineScheduleVaccineID
	, VaccineScheduleID
	, VaccineID
from VaccineScheduleVaccine
where @VaccineScheduleID = VaccineScheduleID
union all
select
	VaccineScheduleVaccineID = convert(int,0)
	, VaccineScheduleID = @VaccineScheduleID
	, VaccineID = convert(int,null)
where @IncludeNew = 1