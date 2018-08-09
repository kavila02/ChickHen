create PROC csb.UserTable_GetList
AS

declare @loop table (UserTableID int, Locations nvarchar(2000), flag bit)
insert into @loop select UserTableID, '', 0 from csb.UserTable
declare @currentUser int, @location nvarchar(2000)
while exists (select 1 from @loop where flag = 0)
begin
	select top 1 @currentUser = UserTableID, @location='' from @loop where flag = 0
	if exists (select 1 from Location l left outer join UserToLocation utl on utl.LocationID = l.LocationID and utl.UserTableID = @currentUser where utl.UserToLocationID is null)
	begin
		select @location = @location + case when @location = '' then '' else ', ' end + Location
			from csb.UserTable ut
			inner join UserToLocation utl on ut.UserTableID = utl.UserTableID
			inner join Location l on utl.LocationID = l.LocationID
		where ut.UserTableID = @currentUser
	end
	else
	begin
		select @location = 'All Locations'
	end
	update @loop set Locations = @location, flag = 1 where UserTableID = @currentUser
end

SELECT
    ut.UserTableID
    , UserID
    , EmailAddress
    , UserGroupID
    , ContactName
    , Inactive
	, case when IsNull(l.Locations,'') = '' then '{add}' else l.Locations end as Locations
FROM csb.userTable ut
left outer join @loop l on ut.UserTableID = l.UserTableID
UNION ALL
SELECT
    ''
    , ''
    , ''
    , ''
    , ''
    , CONVERT(BIT, 0)
	, NULL