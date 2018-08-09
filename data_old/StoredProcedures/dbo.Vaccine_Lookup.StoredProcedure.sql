if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Vaccine_Lookup' and s.name = 'dbo')
begin
	drop proc Vaccine_Lookup
end
GO
create proc Vaccine_Lookup
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select rtrim(VaccineName) + ' (' + case when IsNull(ActiveStartDate,'1/1/1900') = '1/1/1900' then 'Until '
										else convert(varchar,ActiveStartDate,101) + ' - '
										end
								+ case when IsNull(ActiveEndDate,'1/1/1900') = '1/1/1900' then 'present'
										else convert(varchar,ActiveEndDate,101)
										end
						+ ')'
		As VaccineDisplay
	,VaccineID
	,IsNull(SortOrder,0)
from Vaccine
where GETDATE() between ActiveStartDate and case when IsNull(ActiveEndDate,'1/1/1900') = '1/1/1900' then '1/1/9999' else ActiveEndDate end

union all
select '','',-1
where @IncludeBlank = 1

union all
select 'All','',-1
where @IncludeAll = 1

Order by 3,1