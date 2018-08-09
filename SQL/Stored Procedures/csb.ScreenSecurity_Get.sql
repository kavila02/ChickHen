create proc csb.ScreenSecurity_Get
@MenuID varchar(100) = ''
,@ScreenID varchar(255) = ''
,@MenuDisplay varchar(255) = ''
,@DefaultPermission varchar(5) = 'allow'
,@PagePartTypeID int = 1
AS

--If there's a screen id use that. Otherwise use the menuID
if IsNull(@ScreenID,'') = ''
	select @ScreenID = XmlScreenID from csb.PagePart where MenuID = @MenuID

--If record doesn't exist, create it
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

select 
	XmlScreenID as ScreenID
	,@MenuDisplay As MenuDisplay
	,case when IsViewableDefault = 1 or IsReadOnly = 1 then 1
		else -1
		end As DefaultPermission
	,PagePartID
from csb.PagePart
where (IsNull(@ScreenID,'') = '' and MenuID = @MenuID)
or @ScreenID = XmlScreenID