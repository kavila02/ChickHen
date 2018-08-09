if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Detail_Status_Lookup' and s.name = 'dbo')
begin
	drop proc Detail_Status_Lookup
end
GO

create proc Detail_Status_Lookup
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select Detail_Status,Detail_StatusID,SortOrder
from Detail_Status
where IsActive = 1

union all
select '','',0
where @IncludeBlank = 1

union all
select 'All','',0
where @IncludeAll = 1

Order by SortOrder