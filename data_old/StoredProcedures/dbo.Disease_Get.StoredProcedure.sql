if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Disease_Get' and s.name = 'dbo')
begin
	drop proc Disease_Get
end
GO
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
