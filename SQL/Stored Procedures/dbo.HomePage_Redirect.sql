
create proc HomePage_Redirect
@UserName nvarchar(255)
AS

declare @LocationID int
if (select count(1) from UserToLocation utl inner join csb.UserTable ut on utl.UserTableID = ut.UserTableID where ut.UserID = @UserName) = 1
begin
	select @LocationID = LocationID from UserToLocation utl inner join csb.UserTable ut on utl.UserTableID = ut.UserTableID where ut.UserID = @UserName
end

select
	@LocationID as ID
	,case when @LocationID is null then 'FlockList'
		else 'Location' end as referenceType