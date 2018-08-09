if exists (select 1 from sys.procedures where name = 'ShowOnScreen_Lookup')
begin
	drop proc ShowOnScreen_Lookup
end

GO

create proc ShowOnScreen_Lookup
AS

select 'Checklist', 1
union all select 'Flock', 2
union all select 'All', 3
order by 2

GO