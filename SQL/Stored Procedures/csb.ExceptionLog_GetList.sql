
CREATE PROCEDURE [csb].[ExceptionLog_GetList]
	@SupportIntervalID int,
	@PagePartID int,
	@UserID int,
	@ExceptionSummaryFilter varchar(4000),
	@MethodFilter varchar(4000),
	@UrlFilter varchar(4000)
AS

declare @MAX_LENGTH int = 80

select l.ExceptionLogID, l.LogDateTime, p.XmlScreenID, u.FullName as UserFullName,
		case when LEN(l.ExceptionSummary) > @MAX_LENGTH 
			then SUBSTRING(l.ExceptionSummary, 0, @MAX_LENGTH) + '...' 
			else l.ExceptionSummary end as ExceptionSummary,
		l.Method,
		case when LEN(l.Url) > @MAX_LENGTH 
			then SUBSTRING(l.Url, 0, @MAX_LENGTH) + '...' 
			else l.Url end as Url
	from csb.ExceptionLog l
	join csb.SupportInterval si on si.SupportIntervalID = @SupportIntervalID
	left join csb.PagePart p on l.PagePartID = p.PagePartID
	left join csb.[User] u on l.UserID = u.UserID
	where l.LogDateTime > DATEADD(MINUTE, -si.MinuteCount, SYSDATETIME())
		and @PagePartID in (-1, l.PagePartID)
		and @UserID in (0, l.UserID)
		and l.ExceptionSummary like '%' + @ExceptionSummaryFilter + '%'
		and l.Method like '%' + @MethodFilter + '%'
		and l.Url like '%' + @UrlFilter + '%'
	order by l.LogDateTime desc, l.ExceptionLogID desc