
create proc [dbo].[DatePart_Lookup]
AS

select 'Days', 'dd', 1
union select 'Weeks', 'wk', 2
union select 'Months', 'mm', 3
union select 'Years', 'yyyy', 4
order by 3