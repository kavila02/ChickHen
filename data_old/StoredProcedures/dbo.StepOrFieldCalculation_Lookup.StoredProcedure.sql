if exists (select 1 from sys.procedures where name = 'StepOrFieldCalculation_Lookup')
begin
	drop proc StepOrFieldCalculation_Lookup
end

GO

create proc StepOrFieldCalculation_Lookup
AS

select 'Date Based on Step', 1
union all select 'Date Based on Field', 2
union all select 'Manual Entry', 3
order by 2

GO