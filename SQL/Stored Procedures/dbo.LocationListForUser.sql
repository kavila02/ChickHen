create proc LocationListForUser
	@UserName nvarchar(255) = ''
AS

select
	l.LocationID
	,l.Location
from Location l 
inner join UserToLocation utl on utl.LocationID = l.LocationID
inner join csb.UserTable ut on utl.UserTableID = ut.UserTableID
where ut.UserID = @UserName
order by l.Location