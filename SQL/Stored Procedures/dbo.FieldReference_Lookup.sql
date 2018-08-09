
create proc FieldReference_Lookup
AS

select FriendlyName, FieldReferenceID, SortOrder
from FieldReference
where IsActive = 1
and DateField = 1

order by 3