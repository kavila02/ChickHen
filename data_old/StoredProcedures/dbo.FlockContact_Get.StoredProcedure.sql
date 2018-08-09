if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockContact_Get' and s.name = 'dbo')
begin
	drop proc FlockContact_Get
end
GO

create proc FlockContact_Get
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
