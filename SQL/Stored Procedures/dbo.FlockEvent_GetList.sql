create proc FlockEvent_GetList
@FlockID int
,@UserName nvarchar(255) = ''
,@IncludeNew bit = 0
As

select
	FlockEventID
	, EventDescription
	, FollowUpDescription
	, cut.ContactName as CreatedBy_User
	, fuut.ContactName as FollowUpCreatedBy_User
	, c.ContactName as FollowUpContact
	, fe.FlockID
	, 'Flock Events for ' + f.FlockName as titleText
	, @UserName as UserName
	, EventDate
	, 1 as sortOrder
from FlockEvent fe
left outer join csb.UserTable cut on fe.CreatedBy_UserTableID = cut.UserTableID
left outer join csb.UserTable fuut on fe.FollowUpCreatedBy_UserTableID = fuut.UserTableID
left outer join Flock f on fe.FlockID = f.FlockID
left outer join Contact c on fe.FollowUpContact = c.ContactID
where @FlockID = fe.FlockID

union all
select
	FlockEventID = convert(int,0)
	, EventDescription = convert(varchar(255),null)
	, FollowUpDescription = convert(varchar(255),null)
	, CreatedBy_User = ''
	, FollowUpCreatedBy_User = ''
	, FollowUpContact = ''
	, FlockID = convert(int,@FlockID)
	, 'Flock Events for ' + FlockName as titleText
	, @UserName as UserName
	, null as EventDate
	, 0 as sortOrder
from Flock 
where FlockID = @FlockID
and not exists (Select 1 from FlockEvent where FlockID = @FlockID)
order by sortOrder, EventDate desc