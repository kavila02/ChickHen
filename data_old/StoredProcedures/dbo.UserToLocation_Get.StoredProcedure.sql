if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'UserToLocation_Get' and s.name = 'dbo')
begin
	drop proc UserToLocation_Get
end
GO
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
