
create procedure [csb].[ActivityLog_Get]
	@ActivityLogID int
as

select l.ActivityLogID, l.LogDateTime, u.FullName as UserFullName,
		p.XmlScreenID, l.IsPost, l.IpAddress, l.Url, l.UserAgent
	from csb.ActivityLog l
	left join csb.[User] u on l.UserID = u.UserID
	left join csb.PagePart p on l.PagePartID = p.PagePartID
	where l.ActivityLogID = @ActivityLogID