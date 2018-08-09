
create procedure [csb].[ExceptionLog_Get]
	@ExceptionLogID int
as

select l.ExceptionLogID, l.LogDateTime, u.FullName as UserFullName,
		p.XmlScreenID, l.Method, l.Url, l.ExceptionSummary,
		l.ExceptionDetails, l.FormVariables, l.ServerVariables
	from csb.ExceptionLog l
	left join csb.[User] u on l.UserID = u.UserID
	left join csb.PagePart p on l.PagePartID = p.PagePartID
	where l.ExceptionLogID = @ExceptionLogID