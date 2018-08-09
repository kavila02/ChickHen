if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'Flock_GetList' and s.name = 'dbo')
begin
	drop proc Flock_GetList
end
GO
create proc [dbo].[Flock_GetList]
@UserName nvarchar(255) = ''
As

declare @maxFlock table (LayerHouseID int, HatchDate_First date)
insert into @maxFlock (LayerHouseID, HatchDate_First)
select
	lh.LayerHouseID
	,Max(HatchDate_First)
from LayerHouse lh
	inner join Flock f on lh.LayerHouseID = f.LayerHouseID
group by lh.LayerHouseID

select
	f.FlockID
	, f.FlockName
	, f.LayerHouseID
	--, ProductBreedID
	--, Quantity
	--, ServicesNotes
	--, FlockNumber
	--, NPIP
	--, OldOutDate
	--, PulletsMovedID
	--, NumberChicksOrdered
	--, OldFowlHatchDate
	--, ServiceTechID
	--, TotalHoused
	--, HousingOutDate
	--, FowlRemoved
	--, FowlOutID
	--, HatchDate_First
	--, HatchDate_Last
	, f.HatchDate_First
	--, HousingDate_First
	--, HousingDate_Last
	, f.HousingDate_Average
	--, OrderNumber
	, @UserName As UserName
	, IsNull(fc.FlockChecklistName,'') as FlockChecklistName
	, IsNull(fc.FlockChecklistID,0) as FlockChecklistID
	, rtrim(l.Location) + ' - ' + rtrim(LayerHouseName) as LayerHouse
	, f.FlockName + 
		case when GETDATE() between f.HousingDate_First and f.HousingOutDate then
		' <i title="Currently Housed" style="vertical-align: bottom;" class="material-icons ng-binding ng-scope">home</i>'
		else '' end +
		case when mf.LayerHouseID is not null then
		' <i title="Last Flock Ordered for this House" style="vertical-align: bottom;" class="material-icons ng-binding ng-scope">watch_later</i>'
		else '' end
		as FlockNamePlusCurrentHouse
from Flock f
left outer join FlockChecklist fc on f.FlockID = fc.FlockID
left outer join LayerHouse lh on f.LayerHouseID = lh.LayerHouseID
left outer join Location l on lh.LocationID = l.LocationID
left outer join @maxFlock mf on f.HatchDate_First = mf.HatchDate_First and f.LayerHouseID = mf.LayerHouseID
where l.LocationID in (select utl.LocationID from UserToLocation utl
inner join csb.UserTable ut on utl.UserTableID = ut.UserTableID
where ut.UserID = @UserName)
or l.LocationID is null

