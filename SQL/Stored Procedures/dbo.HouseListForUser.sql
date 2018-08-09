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