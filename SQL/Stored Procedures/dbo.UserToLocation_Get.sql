create proc UserToLocation_Get
@UserTableID int
,@IncludeNew bit = 1
As

select
	utl.UserToLocationID
	, utl.UserTableID
	, utl.LocationID
	, ut.ContactName
	, 'Locations for ' + rtrim(ut.ContactName) as header
from UserToLocation utl
inner join csb.UserTable ut on utl.UserTableID = ut.UserTableID
where @UserTableID = utl.UserTableID
union all
select
	UserToLocationID = convert(int,0)
	, UserTableID = UserTableID
	, LocationID = convert(int,null)
	, ContactName = ContactName
	, 'Locations for ' + rtrim(ContactName) as header
from csb.UserTable
where @IncludeNew = 1
	and UserTableID = @UserTableID