if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockChecklistCalendar_Get' and s.name = 'dbo')
begin
	drop proc FlockChecklistCalendar_Get
end
GO
create proc FlockChecklistCalendar_Get
@UserName nvarchar(255) = ''
AS

select
	DateOfAction
	,rtrim(f.FlockName) + '- ' + rtrim(d.StepName) as StepName
	,d.FlockChecklist_DetailID
	,--'Description: ' + 
	rtrim(d.ActionDescription)
	as hoverContent
From FlockChecklist fc
inner join FlockChecklist_Detail d on fc.FlockChecklistID = d.FlockChecklistID
inner join Flock f on fc.FlockID = f.FlockID
inner join LayerHouse lh on f.LayerHouseID = lh.LayerHouseID
inner join UserToLocation utl on utl.LocationID = lh.LocationID
inner join csb.UserTable ut on ut.UserID = @UserName and utl.UserTableID = ut.UserTableID
left outer join ContactRole r on d.OriginatorID = r.ContactRoleID
order by StepName