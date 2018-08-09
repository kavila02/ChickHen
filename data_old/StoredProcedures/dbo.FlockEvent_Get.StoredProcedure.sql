if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockEvent_Get' and s.name = 'dbo')
begin
	drop proc FlockEvent_Get
end
GO
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
