
create procedure [csb].[PerformanceLogEntryType_GetList]
	@IncludeAll bit = 0
as
	select t.Name, t.PerformanceLogEntryTypeID, t.DisplaySequence
		from csb.PerformanceLogEntryType t
	union
	select 'All', -1, 0
		where @IncludeAll = 1
	order by DisplaySequence, Name