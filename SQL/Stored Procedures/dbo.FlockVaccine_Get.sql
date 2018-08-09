
create proc FlockVaccine_Get
@FlockID int = null
,@FlockVaccineID int = null
,@IncludeNew bit = 1
As

select
	FlockVaccineID
	, FlockID
	, fv.VaccineID
	, VaccineStatusID
	, FlockVaccineNotes
	, ScheduledDate
	, CompletedDate
	, convert(bit,0) as newRecord
	, IsNull(v.VaccineName,'{New Record- please select vaccine}') as VaccineName
from FlockVaccine fv
left outer join Vaccine v on fv.VaccineID = v.VaccineID
where IsNull(@FlockID,FlockID) = FlockID
and IsNull(@FlockVaccineID,FlockVaccineID) = FlockVaccineID
union all
select
	FlockVaccineID = convert(int,0)
	, FlockID = @FlockID
	, VaccineID = convert(int,null)
	, VaccineStatusID = convert(int,null)
	, FlockVaccineNotes = convert(nvarchar(4000),null)
	, ScheduledDate = convert(date,null)
	, CompletedDate = convert(date,null)
	, convert(bit,1) as newRecord
	, '' as VaccineName
where @IncludeNew = 1