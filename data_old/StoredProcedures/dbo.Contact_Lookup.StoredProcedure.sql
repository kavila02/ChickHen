if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Contact_Lookup' and s.name = 'dbo')
begin
	drop proc Contact_Lookup
end
GO





create proc Contact_Lookup
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select ContactName,ContactID,1
from Contact
where Active = 1

union all
select '','',0
where @IncludeBlank = 1

union all
select 'All','',0
where @IncludeAll = 1


order by 3,1


