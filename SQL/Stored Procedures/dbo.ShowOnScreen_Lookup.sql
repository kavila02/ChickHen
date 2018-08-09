
create proc [dbo].[ShowOnScreen_Lookup]
AS

select 'Checklist', 1
union all select 'Flock', 2
union all select 'All', 3
order by 2