create proc VaccineDisease_Get
@VaccineID int = null
,@IncludeNew bit = 1
As

select
	VaccineDiseaseID
	, vd.VaccineID
	, DiseaseID
	, 'Diseases for ' + rtrim(VaccineName) as heading
from VaccineDisease vd
inner join Vaccine v on vd.VaccineID = v.VaccineID
where @VaccineID = v.VaccineID
union all
select
	VaccineDiseaseID = convert(int,0)
	, VaccineID = @VaccineID
	, DiseaseID = convert(int,null)
	, 'Diseases for ' + rtrim(VaccineName) as heading
from Vaccine where VaccineID = @VaccineID
and @IncludeNew = 1