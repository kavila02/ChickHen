if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'VaccineStatus_Lookup' and s.name = 'dbo')
begin
	drop proc VaccineStatus_Lookup
end
GO
create proc VaccineStatus_Lookup
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select VaccineStatus,VaccineStatusID,SortOrder
from VaccineStatus
where IsActive = 1

union all
select '','',0
where @IncludeBlank = 1

union all
select 'All','',0
where @IncludeAll = 1

Order by SortOrder