if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FieldReference_Lookup' and s.name = 'dbo')
begin
	drop proc FieldReference_Lookup
end
GO

create proc FieldReference_Lookup
AS

select FriendlyName, FieldReferenceID, SortOrder
from FieldReference
where IsActive = 1
and DateField = 1

order by 3