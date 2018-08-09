
create procedure [csb].[SolutionObjectType_GetList]
	@IncludeAll bit = 0
as

select o.TypeName + ' (' + convert(varchar, count(*)) + ')' as Name, 
		o.SolutionObjectTypeCode, 2 as DisplaySequence
	from csb.SolutionObject o
	group by o.TypeName, o.SolutionObjectTypeCode
union
select 'All', '%', 1
	where @IncludeAll = 1
order by DisplaySequence, Name