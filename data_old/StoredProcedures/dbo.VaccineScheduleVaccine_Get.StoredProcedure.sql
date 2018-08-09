if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'VaccineScheduleVaccine_Get' and s.name = 'dbo')
begin
	drop proc VaccineScheduleVaccine_Get
end
GO
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
