if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Location_Lookup' and s.name = 'dbo')
begin
	drop proc Location_Lookup
end
GO

create proc [dbo].[Location_Lookup]
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
	,@UserName nvarchar(255) = ''
As

select distinct l.Location,l.LocationID,1, FolderName
from Location l
--where IsActive = 1
left outer join UserToLocation ul on l.LocationID = ul.LocationID
left outer join csb.UserTable ut on ul.UserTableID = ut.UserTableID and ut.UserID = @UserName
where IsNull(@UserName,'') = '' or ut.UserTableID is not null

union all
select '','',0,''
where @IncludeBlank = 1

union all
select 'All','',0,''
where @IncludeAll = 1

Order by 3,1
