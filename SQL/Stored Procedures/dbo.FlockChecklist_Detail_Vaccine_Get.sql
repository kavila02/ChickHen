create proc FlockChecklist_Detail_Vaccine_Get
@FlockChecklist_DetailID int
,@IncludeNew bit = 1
As

select
	FlockChecklist_Detail_VaccineID
	, FlockChecklist_DetailID
	, VaccineID
from FlockChecklist_Detail_Vaccine
where FlockChecklist_DetailID = @FlockChecklist_DetailID
union all
select
	FlockChecklist_Detail_VaccineID = convert(int,0)
	, FlockChecklist_DetailID = @FlockChecklist_DetailID
	, VaccineID = convert(int,null)
where @IncludeNew = 1