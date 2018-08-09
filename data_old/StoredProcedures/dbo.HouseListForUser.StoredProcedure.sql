if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'HouseListForUser' and s.name = 'dbo')
begin
	drop proc HouseListForUser
end
GO
create proc HouseListForUser
	@UserName nvarchar(255) = ''
AS

select
	lh.LayerHouseID
from LayerHouse lh
inner join Location l on lh.LocationID = l.LocationID
inner join UserToLocation utl on utl.LocationID = l.LocationID
inner join csb.UserTable ut on utl.UserTableID = ut.UserTableID
where ut.UserID = @UserName