if exists (Select 1 from sys.objects where name = 'HomePage_FlockList' and type='P')
begin
	drop proc HomePage_FlockList
end
go

create proc [dbo].[HomePage_FlockList]
@UserName nvarchar(255) = ''
,@LocationID int = null
,@LayerHouseID int = null
,@ShowFuture bit = 0
AS

select @LocationID = NullIf(@LocationID,0)
	,@LayerHouseID = NullIf(@LayerHouseID,0)

declare @pulletInfo table (FlockID int, PulletGrower nvarchar(2000))
insert into @pulletInfo (FlockID) select FlockID from Flock --where HousingOutDate > GETDATE()

declare @currentPullet nvarchar(2000), @currentID int
while exists (select 1 from @pulletInfo where PulletGrower is null)
begin
	select top 1 @currentID = FlockID, @currentPullet = '' from @pulletInfo where PUlletGrower is null

	select @currentPullet = @currentPullet + case when @currentPullet = '' then '' else '<br/>' end
							+ rtrim(pg.PulletGrower) + ' (' + convert(varchar,dbo.FormatIntComma(fpg.TotalHoused)) + ' housed)'
			from FlockPulletGrower fpg
			inner join PulletGrower pg on fpg.PulletGrowerID = pg.PulletGrowerID
			where fpg.FlockID = @currentID

	update @pulletInfo set PulletGrower = @currentPullet where FlockID = @currentID
end

select
f.FlockName
,l.Location
,l.LocationID
,lh.LayerHouseName
,f.HatchDate_First
,DATEDIFF(wk, f.HatchDate_First,GETDATE()) as CurrentAge_Weeks
,f.HousingDate_Average
,DATEDIFF(wk,HatchDate_First,HousingDate_Average) As AgeAtHousing_Weeks
,dbo.FormatIntComma(f.TotalChicksPlaced) as AmtOfBirds --So I see why quantity was a different number. Number placed is different than the current quantity. Maybe consider putting it back in
,pb.ProductBreed
,f.HousingOutDate as FowlOutDate
,DATEDIFF(wk, f.HatchDate_First, f.HousingOutDate) as HousingOutAge_Weeks	
,p.PulletGrower
,dbo.FormatIntComma(f.NumberChicksOrdered) as NumberChicksOrdered
from
Flock f
left outer join LayerHouse lh on f.LayerHouseID = lh.LayerHouseID
left outer join Location l on lh.LocationID = l.LocationID
left outer join ProductBreed pb on f.ProductBreedID = pb.ProductBreedID
left outer join @pulletInfo p on f.FlockID = p.FlockID
where 
(GETDATE() between f.HousingDate_First and IsNull(f.HousingOutDate,'1/1/9999') --only current flock
or @ShowFuture = 1
)
and 
l.LocationID in (select LocationID from UserToLocation utl inner join csb.UserTable ut on utl.UserTableID = ut.UserTableID where ut.UserID = @UserName)
and l.LocationID = IsNull(@LocationID,l.LocationID)
and lh.LayerHouseID = IsNull(@LayerHouseID,lh.LayerHouseID)
order by f.HousingDate_Average
