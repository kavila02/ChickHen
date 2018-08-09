if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FowlOutMover_Get' and s.name = 'dbo')
begin
	drop proc FowlOutMover_Get
end
GO
create proc FowlOutMover_Get
@FowlOutMoverID int = null
,@IncludeNew bit = 1
As

select
	FowlOutMoverID
	, FowlOutMover
	, SortOrder
	, IsActive
from FowlOutMover
where IsNull(@FowlOutMoverID,FowlOutMoverID) = FowlOutMoverID
union all
select
	FowlOutMoverID = convert(int,0)
	, FowlOutMover = convert(nvarchar(255),null)
	, SortOrder = convert(int,IsNull((Select MAX(SortOrder) + 1 from FowlOutMover),1))
	, IsActive = convert(bit,null)
where @IncludeNew = 1
Order by SortOrder