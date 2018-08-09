if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'UserAddAllLocations' and s.name = 'dbo')
begin
	drop proc UserAddAllLocations
end
GO
create PROC UserAddAllLocations
	@UserTableID int
	
AS

insert into UserToLocation (UserTableID, LocationID)
select @UserTableID, l.LocationID
from Location l
left outer join UserToLocation utl on l.LocationID = utl.LocationID and utl.UserTableID = @UserTableID
where utl.UserToLocationID is null