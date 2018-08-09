create proc ChecklistTemplate_Detail_Vaccine_Get
@ChecklistTemplate_DetailID int
,@IncludeNew bit = 1
As

select
	ChecklistTemplate_Detail_VaccineID
	, ChecklistTemplate_DetailID
	, VaccineID
from ChecklistTemplate_Detail_Vaccine
where ChecklistTemplate_DetailID = @ChecklistTemplate_DetailID
union all
select
	ChecklistTemplate_Detail_VaccineID = convert(int,0)
	, ChecklistTemplate_DetailID = @ChecklistTemplate_DetailID
	, VaccineID = convert(int,null)
where @IncludeNew = 1