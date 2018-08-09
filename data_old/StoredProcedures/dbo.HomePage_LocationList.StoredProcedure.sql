if exists (Select 1 from sys.objects where name = 'HomePage_LocationList' and type='P')
begin
	drop proc HomePage_LocationList
end
go

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