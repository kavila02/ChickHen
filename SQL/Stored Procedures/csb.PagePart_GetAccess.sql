
CREATE proc [csb].[PagePart_GetAccess]
	@UserName varchar(255)
as

select IsNull(p.XmlScreenID,'') as XmlScreenID, 
		IsNull(p.MenuID,'') as MenuID,
		ISNULL(gp.IsViewable, p.IsViewableDefault) as IsViewable, 
		ISNULL(gp.IsUpdatable, p.IsUpdatableDefault) as IsUpdatable
	from csb.[User] u 
		cross join csb.PagePart p
		left join csb.UserGroupPagePart gp 
			on u.UserGroupID = gp.UserGroupID
			and p.PagePartID = gp.PagePartID 
	where u.UserName = @UserName