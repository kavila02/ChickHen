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