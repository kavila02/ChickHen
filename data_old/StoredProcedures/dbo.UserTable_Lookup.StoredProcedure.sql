if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'UserTable_Lookup' and s.name = 'dbo')
begin
	drop proc UserTable_Lookup
end
GO
create proc UserTable_Lookup
AS

select ContactName + ' (' + UserID + ')', UserTableID
from csb.UserTable
order by 1