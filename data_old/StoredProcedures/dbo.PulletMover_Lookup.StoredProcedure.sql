if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'PulletMover_Lookup' and s.name = 'dbo')
begin
	drop proc PulletMover_Lookup
end
GO




create proc PulletMover_Lookup
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select PulletMover,PulletMoverID,SortOrder
from PulletMover
where IsActive = 1

union all
select '','',0
where @IncludeBlank = 1

union all
select 'All','',0
where @IncludeAll = 1

order by 3


