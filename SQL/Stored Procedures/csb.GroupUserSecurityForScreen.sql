
create proc csb.GroupUserSecurityForScreen
@MenuID varchar(100) = ''
,@ScreenID varchar(255) = ''
,@DefaultPermission varchar(5) = 'allow'
,@PagePartTypeID int = 1
AS

insert into csb.PagePart(PagePartTypeID, XmlScreenID, IsReadOnly, IsViewableDefault, IsUpdatableDefault, MenuID)
select
	@PagePartTypeID
	, @ScreenID
	, 0
	, case when @DefaultPermission = 'allow' then 1 else 0 end
	, case when @DefaultPermission = 'allow' then 1 else 0 end
	, @MenuID
where not exists
(select 1
from csb.PagePart
where (IsNull(@ScreenID,'') = '' and MenuID = @MenuID)
or @ScreenID = XmlScreenID
)

declare @PagePartID int
select @PagePartID = PagePartID from csb.PagePart
where (IsNull(@ScreenID,'') = '' and MenuID = @MenuID)
		or @ScreenID = XmlScreenID

select
	NULL as link
	,UserGroup as Name
	,'group' as Type
	, case when ugpp.UserGroupPagePartID is null then 'Read/Write'
		when ISNULL(ugpp.IsViewable, pp.IsViewableDefault) = 1 and ISNULL(ugpp.IsUpdatable, pp.IsUpdatableDefault) = 1 then 'Read/Write'
		when ISNULL(ugpp.IsViewable, pp.IsViewableDefault) = 1 and ISNULL(ugpp.IsUpdatable, pp.IsUpdatableDefault) = 0 then 'Read Only'
		when ISNULL(ugpp.IsViewable, pp.IsViewableDefault) = 0 then 'No Access'
		else 'Read/Write' end as EffectivePermission
	, case when ugpp.UserGroupPagePartID is null then Null
		when ugpp.IsUpdatable = 1 and ugpp.IsViewable = 1 then 'Read/Write'
		when ugpp.IsViewable = 1 and ugpp.IsUpdatable = 0 then 'Read Only'
		when ugpp.IsViewable = 0 then 'No Access'
		else Null end as ExplicitPermission
	, ug.UserGroupID
	, IsNull(ugpp.UserGroupPagePartID,0) as UserGroupPagePartID
	, pp.PagePartID
from csb.UserGroup ug
cross join csb.PagePart pp 
left outer join csb.UserGroupPagePart ugpp
	on ug.UserGroupID = ugpp.UserGroupID and ugpp.PagePartID = pp.PagePartID
where pp.PagePartID = @PagePartID