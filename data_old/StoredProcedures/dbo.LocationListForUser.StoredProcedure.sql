if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'LocationListForUser' and s.name = 'dbo')
begin
	drop proc LocationListForUser
end
GO
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