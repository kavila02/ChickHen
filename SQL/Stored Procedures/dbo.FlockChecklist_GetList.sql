CREATE proc [dbo].[FlockChecklist_GetList]
@FlockID int = 0
,@UserName nvarchar(255) = ''
As

Select
	FlockChecklistID
	,rtrim(FlockChecklistName) as FlockChecklistName
	,(Select top 1 rtrim(StepName) + ' - ' + convert(nvarchar,DateOfAction,101) from FlockChecklist_Detail d where fc.FlockChecklistID = d.FlockChecklistID and CompletedDate is null order by DateOfAction)
		As NextStep
	,f.FlockName
	,f.FlockID
from FlockChecklist fc
inner join Flock f on fc.FlockID = f.FlockID
left outer join LayerHouse lh on f.LayerHouseID = lh.LayerHouseID
left outer join Location l on lh.LocationID = l.LocationID
Where @FlockID in (fc.FlockID, 0)
and (l.LocationID in (select utl.LocationID from UserToLocation utl
inner join csb.UserTable ut on utl.UserTableID = ut.UserTableID
where ut.UserID = @UserName)
or l.LocationID is null)