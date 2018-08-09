
create proc [dbo].[FlockContact_Get]
@FlockID int
,@IncludeNew bit = 1
As

select
	FlockContactID
	, FlockID
	, ContactRoleID
	, ContactID
from FlockContact
where @FlockID = FlockID
union all
select
	FlockContactID = convert(int,0)
	, FlockID = @FlockID
	, ContactRoleID = convert(int,null)
	, ContactID = convert(int,null)
where @IncludeNew = 1