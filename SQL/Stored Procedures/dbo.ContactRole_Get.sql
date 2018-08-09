

create proc [dbo].[ContactRole_Get]
@ContactRoleID int = null
,@IncludeNew bit = 1
As

select
	ContactRoleID
	, RoleName
from ContactRole
where IsNull(@ContactRoleID,ContactRoleID) = ContactRoleID
union all
select
	ContactRoleID = convert(int,0)
	, RoleName = convert(nvarchar(255),null)
where @IncludeNew = 1