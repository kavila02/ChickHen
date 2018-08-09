create PROC UserAddAllLocations
	@UserTableID int
	
AS

insert into UserToLocation (UserTableID, LocationID)
select @UserTableID, l.LocationID
from Location l
left outer join UserToLocation utl on l.LocationID = utl.LocationID and utl.UserTableID = @UserTableID
where utl.UserToLocationID is null