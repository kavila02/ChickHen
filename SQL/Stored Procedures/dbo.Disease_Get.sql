create proc Disease_Get
@IncludeNew bit = 1
As

select
	DiseaseID
	, DiseaseName
	, SortOrder
	, IsActive
from Disease

union all
select
	DiseaseID = convert(int,0)
	, DiseaseName = convert(varchar(100),null)
	, SortOrder = convert(int,null)
	, IsActive = convert(bit,null)
where @IncludeNew = 1