if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockChecklist_Detail_Vaccine_Get' and s.name = 'dbo')
begin
	drop proc FlockChecklist_Detail_Vaccine_Get
end
GO
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
