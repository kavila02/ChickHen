CREATE proc [dbo].[HouseInformation_Get]
	@ReportDate date = null
	,@LocationID int = null
	,@ChecklistTemplateID int = null
	,@IncludeFuture bit = 0
	,@UserName nvarchar(255) = ''
AS

if @ReportDate is null
	select @ReportDate = GETDATE()
if @LocationID = ''
	select @LocationID = null
if @ChecklistTemplateID = ''
	select @ChecklistTemplateID = null

select
	f.FlockName
	,f.FlockNumber
	,pb.ProductBreed
	,rtrim(l.Location) + ' - ' + rtrim(lh.LayerHouseName) as LayerHouse
	,lh.HouseStyle
	,lh.BirdCapacity
	,lh.CageHeight
	,lh.CageWidth
	,lh.CageDepth
	,f.HatchDate_Average
	--,f.HousingDate_Average
	,f.HousingDate_First
	,prevF.FlockName as PrevFlockName
	,IsNull(f.OldOutDate,prevF.HousingOutDate) as PrevFlockHousingOutDate
	,IsNull(f.OldFowlHatchDate,prevF.HatchDate_Average) as PrevFlockHatchDate
	,f.HousingOutDate
	,convert(bit,0) as ShowRecord
	,nextF.FlockName as NextFlockName
	,nextF.HousingDate_First as NextFlockHousingDate
	,nextF.HatchDate_First as NextFlockHatchDate
	,lh.LocationID
from Flock f
inner join LayerHouse lh on f.LayerHouseID = lh.LayerHouseID
inner join Location l on lh.LocationID = l.LocationID
inner join UserToLocation utl on utl.LocationID = l.LocationID
inner join csb.UserTable ut on utl.UserTableID = ut.UserTableID
left outer join ProductBreed pb on f.ProductBreedID = pb.ProductBreedID

--Next flock
left outer join Flock nextF on nextF.FlockID = (select top 1 FlockID from Flock f2 where f2.LayerHouseID = f.LayerHouseID and f2.HousingDate_First > f.HousingDate_First order by f2.HousingDate_First)


--Previous flock
left outer join Flock prevF on prevF.FlockID = (select top 1 FlockID from Flock f2 where f2.LayerHouseID = f.LayerHouseID and f2.HousingDate_First < f.HousingDate_First order by f2.HousingDate_First desc)

--Template Info
left outer join FlockChecklist fc on f.FlockID = fc.FlockID
left outer join ChecklistTemplate ct on fc.ChecklistTemplateID = ct.ChecklistTemplateID

where ut.UserID = @UserName
and case when @IncludeFuture = 0 then
			case when @ReportDate between f.HousingDate_First and IsNull(nextF.HousingDate_First,f.HousingOutDate)
					then 1 else 0 end
		when @IncludeFuture = 1 then
			case when @ReportDate < IsNull(nextF.HousingDate_First,f.HousingOutDate)
				then 1 else 0 end
		else 0 end = 1
and l.LocationID = IsNull(@LocationID,l.LocationID)
and (ct.ChecklistTemplateID is null or @ChecklistTemplateID is null or @ChecklistTemplateID = ct.ChecklistTemplateID)