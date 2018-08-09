if exists (select 1 from sys.procedures where name = 'DatePart_Lookup')
begin
	drop proc DatePart_Lookup
end
GO

create proc DatePart_Lookup
AS

select 'Days', 'dd', 1
union select 'Weeks', 'wk', 2
union select 'Months', 'mm', 3
union select 'Years', 'yyyy', 4
order by 3

GO