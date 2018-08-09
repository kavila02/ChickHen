CREATE proc [dbo].[FlockChecklistCalendar_Get]
@UserName nvarchar(255) = ''
AS

--select
--	DateOfAction as CalendarDate
--	,rtrim(f.FlockName) + '- ' + rtrim(d.StepName) as Display
--	,d.FlockChecklist_DetailID
--	,convert(int,null) as FlockID_ForLink
--	,rtrim(d.ActionDescription)	as hoverContent
--From FlockChecklist fc
--inner join FlockChecklist_Detail d on fc.FlockChecklistID = d.FlockChecklistID
--inner join Flock f on fc.FlockID = f.FlockID
--inner join LayerHouse lh on f.LayerHouseID = lh.LayerHouseID
--inner join UserToLocation utl on utl.LocationID = lh.LocationID
--inner join csb.UserTable ut on ut.UserID = @UserName and utl.UserTableID = ut.UserTableID
--left outer join ContactRole r on d.OriginatorID = r.ContactRoleID
--order by StepName

declare @sql nvarchar(max)
select @sql = 'select
	convert(date,DateOfAction) as CalendarDate
	,rtrim(f.FlockName) + ''- '' + rtrim(d.StepName) as Display
	,d.FlockChecklist_DetailID
	,convert(int,null) as FlockID_ForLink
	,rtrim(d.ActionDescription)	as hoverContent
	,1 as sortOrder
	,''FlockChecklist'' as linkType
	,lh.LocationID
	,f.LayerHouseID
From FlockChecklist fc
inner join FlockChecklist_Detail d on fc.FlockChecklistID = d.FlockChecklistID
inner join Flock f on fc.FlockID = f.FlockID
inner join LayerHouse lh on f.LayerHouseID = lh.LayerHouseID
inner join UserToLocation utl on utl.LocationID = lh.LocationID
inner join csb.UserTable ut on ut.UserID = @UserName and utl.UserTableID = ut.UserTableID
left outer join ContactRole r on d.OriginatorID = r.ContactRoleID
where DateOfAction is not null
'
select @sql = @sql + '
union all select
	convert(date,f.' + FieldName + ') as CalendarDate
	,rtrim(f.FlockName) + ''- '' + ''' + rtrim(FriendlyName) + ''' as Display
	,convert(int,null) as FlockChecklist_DetailID
	,f.FlockID as FlockID_ForLink
	,rtrim(l.Location) + '' '' + rtrim(lh.LayerHouseName)	as hoverContent
	,2 as sortOrder
	,''' + rtrim(TableName) + '.' + rtrim(FieldName) + ''' as linkType
	,l.LocationID
	,lh.LayerHouseID
from Flock f
inner join LayerHouse lh on f.LayerHouseID = lh.LayerHouseID
inner join Location l on lh.LocationID = l.LocationID
inner join UserToLocation utl on utl.LocationID = lh.LocationID
inner join csb.UserTable ut on ut.UserID = @UserName and utl.UserTableID = ut.UserTableID
where f.' + FieldName + ' is not null
'
from FieldReference
where DateField = 1 and IncludeInCalendar = 1

select @sql = @sql + '
order by CalendarDate, sortOrder, Display, linkType'

exec sp_ExecuteSql @sql, N'@UserName nvarchar(255)', @UserName = @UserName