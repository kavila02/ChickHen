
create procedure [csb].[WarningLog_GetList]
	@SupportIntervalID int,
	@PagePartID int,
	@UserID int,
	@WarningFilter varchar(4000),
	@SourceFilter varchar(4000)
as

declare @MAX_LENGTH int = 80

select l.WarningLogID, l.LogDateTime, p.XmlScreenID, u.FullName as UserFullName,
		case when LEN(l.Warning) > @MAX_LENGTH 
			then SUBSTRING(l.Warning, 0, @MAX_LENGTH) + '...' 
			else l.Warning end as Warning,
		case when LEN(l.Source) > @MAX_LENGTH 
			then SUBSTRING(l.Source, 0, @MAX_LENGTH) + '...' 
			else l.Source end as Source
	from csb.WarningLog l
	join csb.SupportInterval si on si.SupportIntervalID = @SupportIntervalID
	left join csb.PagePart p on l.PagePartID = p.PagePartID
	left join csb.[User] u on l.UserID = u.UserID
	where l.LogDateTime > DATEADD(MINUTE, -si.MinuteCount, SYSDATETIME())
		and @PagePartID in (-1, l.PagePartID)
		and @UserID in (0, l.UserID)
		and l.Warning like '%' + @WarningFilter + '%'
		and l.Source like '%' + @SourceFilter + '%'
	order by l.LogDateTime desc, l.WarningLogID desc