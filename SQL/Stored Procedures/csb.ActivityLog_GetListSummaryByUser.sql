
CREATE procedure [csb].[ActivityLog_GetListSummaryByUser]
	@SupportIntervalID int,
	@PagePartID int,
	@UserID int,
	@IpAddressFilter varchar(4000) = '',
	@UrlFilter varchar(4000) = '',
	@UserAgentFilter varchar(4000) = ''
as

select u.UserID, u.FullName, MIN(l.LogDateTime) as FirstLogDateTime, 
		MAX(l.LogDateTime) as LastLogDateTime, COUNT(l.ActivityLogID) as AccessCount,
		COUNT(distinct l.PagePartID) as PageCount, 
		COUNT(distinct l.IpAddress) as IpAddressCount
	from csb.[User] u
	join csb.SupportInterval si on si.SupportIntervalID = @SupportIntervalID
	left join csb.ActivityLog l on u.UserID = l.UserID
		and l.LogDateTime > DATEADD(MINUTE, -si.MinuteCount, SYSDATETIME())
		and l.IpAddress like '%' + @IpAddressFilter + '%'
		and l.Url like '%' + @UrlFilter + '%'
		and l.UserAgent like '%' + @UserAgentFilter + '%'
		and @PagePartID in (-1, l.PagePartID)
	where @UserID in (0, u.UserID)
	group by u.UserID, u.FullName
	order by COUNT(*) desc, LastLogDateTime desc, FirstLogDateTime desc, u.FullName