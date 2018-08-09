
create procedure [csb].[PerformanceLog_GetListSummaryBySupportSubInterval]
	@SupportIntervalID int,
	@SupportSubIntervalID int,
	@PagePartID int,
	@UserID int,
	@PerformanceLogEntryTypeID int,
	@SourceFilter varchar(4000),
	@SourceDetailFilter varchar(4000)
as

select LEFT(CONVERT(varchar(19), l.LogDateTime, 120), 
			ISNULL(ssi.SignificantLength, ssid.SignificantLength))
			+ ISNULL(ssi.InsignificantSuffix, ssid.InsignificantSuffix) as SubInterval, 
		MIN(l.LogDateTime) as FirstLogDateTime, 
		MAX(l.LogDateTime) as LastLogDateTime, 
		COUNT(*) as LogEntryCount,
		COUNT(distinct l.UserID) as UserCount, 
		COUNT(distinct l.PagePartID) as PageCount, 
		COUNT(distinct l.Source) as SourceCount, 
		AVG(l.Milliseconds) as MillisecondsAverage, 
		SUM(cast(l.Milliseconds as bigint)) as MillisecondsSum, 
		MIN(l.Milliseconds) as MillisecondsMin, 
		MAX(l.Milliseconds) as MillisecondsMax
	from csb.PerformanceLog l
	join csb.PerformanceLogEntryType t on l.PerformanceLogEntryTypeID = t.PerformanceLogEntryTypeID
	join csb.SupportInterval si on si.SupportIntervalID = @SupportIntervalID
	join csb.SupportSubInterval ssid on si.DefaultSupportSubIntervalID = ssid.SupportSubIntervalID
	left join csb.SupportSubInterval ssi on ssi.SupportSubIntervalID = @SupportSubIntervalID
	left join csb.PagePart p on l.PagePartID = p.PagePartID
	where l.LogDateTime > DATEADD(MINUTE, -si.MinuteCount, SYSDATETIME())
		and @PagePartID in (-1, l.PagePartID)
		and @UserID in (0, l.UserID)
		and @PerformanceLogEntryTypeID in (-1, l.PerformanceLogEntryTypeID)
		and l.Source like '%' + @SourceFilter + '%'
		and l.SourceDetail like '%' + @SourceDetailFilter + '%'
	group by LEFT(CONVERT(varchar(19), l.LogDateTime, 120), 
			ISNULL(ssi.SignificantLength, ssid.SignificantLength))
			+ ISNULL(ssi.InsignificantSuffix, ssid.InsignificantSuffix)
	order by SubInterval desc