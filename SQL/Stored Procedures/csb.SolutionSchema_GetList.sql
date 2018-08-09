
create procedure [csb].[SolutionSchema_GetList]
	@IncludeAll bit = 0
as

select ss.Description, ss.SchemaName, 2 as SelectSequence, ss.DisplaySequence
	from csb.SolutionSchema ss
union
select 'All', '%', 1, 1
	where @IncludeAll = 1
order by SelectSequence, DisplaySequence