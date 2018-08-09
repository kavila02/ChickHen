
create procedure [csb].[WarningLog_Get]
	@WarningLogID int
as

select l.WarningLogID, l.LogDateTime, u.FullName as UserFullName,
		p.XmlScreenID, l.Source, l.Warning
	from csb.WarningLog l
	left join csb.[User] u on l.UserID = u.UserID
	left join csb.PagePart p on l.PagePartID = p.PagePartID
	where l.WarningLogID = @WarningLogID