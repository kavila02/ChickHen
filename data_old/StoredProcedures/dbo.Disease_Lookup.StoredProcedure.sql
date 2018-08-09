if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Disease_Lookup' and s.name = 'dbo')
begin
	drop proc Disease_Lookup
end
GO
create proc Disease_Lookup
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select DiseaseName,DiseaseID
from Disease
where IsActive = 1

union all
select '',''
where @IncludeBlank = 1

union all
select 'All',''
where @IncludeAll = 1