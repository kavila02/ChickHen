if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_Detail_Vaccine_Get' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_Detail_Vaccine_Get
end
GO
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
