if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ContactRole_Get' and s.name = 'dbo')
begin
	drop proc ContactRole_Get
end
GO


create proc ContactRole_Get
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
