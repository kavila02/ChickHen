if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Detail_Status_Get' and s.name = 'dbo')
begin
	drop proc Detail_Status_Get
end
GO
create proc Detail_Status_Get
@Detail_StatusID int = null
,@IncludeNew bit = 1
As

select
	Detail_StatusID
	, Detail_Status
	, SortOrder
	, IsActive
from Detail_Status
where IsNull(@Detail_StatusID,Detail_StatusID) = Detail_StatusID
union all
select
	Detail_StatusID = convert(int,0)
	, Detail_Status = convert(nvarchar(255),null)
	, SortOrder = convert(int,IsNull((Select MAX(SortOrder) + 1 from Detail_Status),1))
	, IsActive = convert(bit,null)
where @IncludeNew = 1
Order by SortOrder