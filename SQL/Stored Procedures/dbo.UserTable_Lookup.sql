create proc UserTable_Lookup
AS

select ContactName + ' (' + UserID + ')', UserTableID
from csb.UserTable
order by 1