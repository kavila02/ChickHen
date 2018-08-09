if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'PulletGrower_Get' and s.name = 'dbo')
begin
	drop proc PulletGrower_Get
end
GO

create proc PulletGrower_Get
@PulletGrowerID int = null
,@IncludeNew bit = 1
As

select
	PulletGrowerID
	, PulletGrower
	, Address
	, City
	, State
	, Zip
	, SortOrder
	, IsActive
	, Capacity
	, Latitude
	, Longitude
	, Phone
from PulletGrower
where IsNull(@PulletGrowerID,PulletGrowerID) = PulletGrowerID
union all
select
	PulletGrowerID = convert(int,0)
	, PulletGrower = convert(nvarchar(255),null)
	, Address = convert(varchar(100),null)
	, City = convert(varchar,(50),null)
	, State = convert(varchar,(25),null)
	, Zip = convert(varchar,(10),null)
	, SortOrder = convert(int,IsNull((Select MAX(SortOrder) + 1 from PulletGrower),1))
	, IsActive = convert(bit,1)
	, Capacity = convert(int,null)
	, Latitude = convert(numeric(19,5),null)
	, Longitude = convert(numeric(19,5),null)
	, Phone = convert(varchar(20),null)
where @IncludeNew = 1
Order by SortOrder
