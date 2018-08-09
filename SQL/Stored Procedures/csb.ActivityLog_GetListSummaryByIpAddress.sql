
create procedure [csb].[ActivityLog_GetListSummaryByIpAddress]
	@SupportIntervalID int,
	@PagePartID int,
	@UserID int,
	@IpAddressFilter varchar(4000),
	@UrlFilter varchar(4000),
	@UserAgentFilter varchar(4000)
as

select l.IpAddress, MIN(l.LogDateTime) as FirstLogDateTime, 
		MAX(l.LogDateTime) as LastLogDateTime, COUNT(*) as AccessCount,
		COUNT(distinct l.UserID) as UserCount, 
		COUNT(distinct l.PagePartID) as PageCount
	from csb.ActivityLog l
	join csb.SupportInterval si on si.SupportIntervalID = @SupportIntervalID
	where l.LogDateTime > DATEADD(MINUTE, -si.MinuteCount, SYSDATETIME())
		and @PagePartID in (-1, l.PagePartID)
		and @UserID in (0, l.UserID)
		and l.IpAddress like '%' + @IpAddressFilter + '%'
		and l.Url like '%' + @UrlFilter + '%'
		and l.UserAgent like '%' + @UserAgentFilter + '%'
	group by l.IpAddress
	order by COUNT(*) desc, LastLogDateTime desc, FirstLogDateTime desc, l.IpAddress