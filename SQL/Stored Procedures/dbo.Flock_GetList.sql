/****** Object:  StoredProcedure [dbo].[Flock_GetList]    Script Date: 7/27/2018 3:17:03 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Flock_GetList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Flock_GetList]
GO
/****** Object:  StoredProcedure [dbo].[Flock_GetList]    Script Date: 7/27/2018 3:17:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Flock_GetList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[Flock_GetList] AS' 
END
GO
ALTER proc [dbo].[Flock_GetList]
@UserName nvarchar(255) = ''
,@IncludeHistorical bit = 0
,@IncludeCurrentFlock bit = 1
,@IncludeLastFlockOrdered bit = 1
,@IncludeInterimFlocks bit = 1
As

declare @maxFlock table (LayerHouseID int, HatchDate_First date)
insert into @maxFlock (LayerHouseID, HatchDate_First)
select
	lh.LayerHouseID
	,Max(HatchDate_First)
from LayerHouse lh
	inner join Flock f on lh.LayerHouseID = f.LayerHouseID
group by lh.LayerHouseID

;WITH X AS
(
SELECT DISTINCT
f.FlockID
FROM FLock f
left outer join @maxFlock mf on f.HatchDate_First = mf.HatchDate_First and f.LayerHouseID = mf.LayerHouseID
WHERE 
((@IncludeCurrentFlock = 0 AND GETDATE() not between f.HousingDate_First and f.HousingOutDate) OR @IncludeCurrentFlock = 1)
AND ((@IncludeLastFlockOrdered = 0 AND mf.LayerHouseID IS NULL) OR @IncludeLastFlockOrdered = 1)
AND ((@IncludeInterimFlocks = 0 AND (GETDATE() between f.HousingDate_First and f.HousingOutDate OR mf.LayerHouseID IS NOT NULL)) OR @IncludeInterimFlocks = 1)
AND ((@IncludeHistorical = 0 AND GETDATE() <= f.HousingOutDate) OR @IncludeHistorical = 1)
)

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
JOIN X x ON x.FlockID = f.FlockID
left outer join FlockChecklist fc on f.FlockID = fc.FlockID
left outer join LayerHouse lh on f.LayerHouseID = lh.LayerHouseID
left outer join Location l on lh.LocationID = l.LocationID
left outer join @maxFlock mf on f.HatchDate_First = mf.HatchDate_First and f.LayerHouseID = mf.LayerHouseID
where l.LocationID in (select utl.LocationID from UserToLocation utl
inner join csb.UserTable ut on utl.UserTableID = ut.UserTableID
where ut.UserID = @UserName)
or l.LocationID is null
AND ((@IncludeCurrentFlock = 0 AND GETDATE() not between f.HousingDate_First and f.HousingOutDate) OR @IncludeCurrentFlock = 1)
AND ((@IncludeLastFlockOrdered = 0 AND mf.LayerHouseID IS NULL) OR @IncludeLastFlockOrdered = 1)


GO
