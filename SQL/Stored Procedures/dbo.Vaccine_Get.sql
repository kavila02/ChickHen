




create proc Vaccine_Get
@VaccineID int = null
,@IncludeNew bit = 1
As

declare @vaccineDisease table (VaccineID int, DiseaseList nvarchar(500))
insert into @vaccineDisease(VaccineID)
select VaccineID from Vaccine where IsNull(@VaccineID,VaccineID) = VaccineID

declare @currentList nvarchar(500), @currentID int
while exists (select 1 from @vaccineDisease where DiseaseList is null)
begin
	select top 1 @currentList = '', @currentID = VaccineID from @vaccineDisease where DiseaseList is null
	select @currentList = @currentList + case when @currentList = '' then '' else ', ' end + DiseaseName
	from VaccineDisease vd
	inner join Disease d on vd.DiseaseID = d.DiseaseID
	where VaccineID = @currentID
	update @vaccineDisease set DiseaseList = @currentList where VaccineID = @currentID
end

select
	v.VaccineID
	, VaccineName
	, ActiveStartDate
	, ActiveEndDate
	, ReplacementVaccineID
	, case DiseaseList when '' then '{add}' else DiseaseList end as DiseaseList
	, SortOrder
from Vaccine v
left outer join @vaccineDisease vd on v.VaccineID = vd.VaccineID
where IsNull(@VaccineID,v.VaccineID) = v.VaccineID
union all
select
	VaccineID = convert(int,0)
	, VaccineName = convert(nvarchar(255),null)
	, ActiveStartDate = convert(date,GETDATE())
	, ActiveEndDate = convert(date,null)
	, ReplacementVaccineID = convert(int,null)
	, DiseaseList = convert(nvarchar(255),null)
	, SortOrder = convert(int,IsNull((select MAX(SortOrder) from Vaccine),0)+1)
where @IncludeNew = 1
order by SortOrder