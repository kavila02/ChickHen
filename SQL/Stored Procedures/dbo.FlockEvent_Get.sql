create proc FlockEvent_Get
@FlockEventID int
,@UserName nvarchar(255) = ''
As

select
	FlockEventID
	, EventDescription
	, FollowUpDescription
	, CreatedBy_UserTableID
	, FollowUpCreatedBy_UserTableID
	, FollowUpContact
	, FlockID
	, @UserName as UserName
	, EventDate
from FlockEvent
where @FlockEventID = FlockEventID