
create procedure [csb].[PerformanceLog_Get]
	@PerformanceLogID int
as

select l.PerformanceLogID, l.LogDateTime, u.FullName as UserFullName,
		p.XmlScreenID, l.Milliseconds, t.Name as PerformanceLogEntryTypeName, 
		l.Source, l.SourceDetail
	from csb.PerformanceLog l
	join csb.PerformanceLogEntryType t 
		on l.PerformanceLogEntryTypeID = t.PerformanceLogEntryTypeID
	left join csb.[User] u on l.UserID = u.UserID
	left join csb.PagePart p on l.PagePartID = p.PagePartID
	where l.PerformanceLogID = @PerformanceLogID