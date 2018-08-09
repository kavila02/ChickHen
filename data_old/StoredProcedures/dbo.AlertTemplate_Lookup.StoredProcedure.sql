if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'AlertTemplate_Lookup' and s.name = 'dbo')
begin
	drop proc AlertTemplate_Lookup
end
GO

create proc AlertTemplate_Lookup
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select AlertName, AlertTemplateID, SortOrder
from AlertTemplate
where IsActive = 1

union all
select '','',0
where @IncludeBlank = 1

Order by SortOrder