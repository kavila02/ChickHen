
create proc HomePage_LocationList
@UserName nvarchar(255) = ''
AS

select
Location
,l.LocationID
from Location l
inner join UserToLocation utl on l.LocationID = utl.LocationID
inner join csb.UserTable ut on utl.UserTableID = ut.UserTableID
where ut.UserID = @UserName