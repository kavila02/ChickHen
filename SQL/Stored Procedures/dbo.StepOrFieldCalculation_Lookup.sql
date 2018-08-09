
create proc [dbo].[StepOrFieldCalculation_Lookup]
AS

select 'Date Based on Step', 1
union all select 'Date Based on Field', 2
union all select 'Manual Entry', 3
order by 2