create proc HomePage_LocationCard_Detail
@LocationID int
,@futureFlocks bit = 0
AS

select
	lh.LayerHouseName
	,lh.LayerHouseID
	,f.HatchDate_First
	,DATEDIFF(wk, f.HatchDate_First,GETDATE()) as CurrentAge_Weeks
	,f.HousingDate_Average
	,DATEDIFF(wk,HatchDate_Average,HousingDate_Average) As AgeAtHousing_Weeks
	,dbo.FormatIntComma(f.TotalChicksPlaced) as AmtOfBirds --So I see why quantity was a different number. Number placed is different than the current quantity. Maybe consider putting it back in
	,pb.ProductBreed
	,f.HousingOutDate as FowlOutDate
	,DATEDIFF(wk, f.HatchDate_First, f.HousingOutDate) as HousingOutAge_Weeks
	,CONCAT(lh.LayerHouseID,'&p=',CONVERT(varchar(15),GETDATE(),1)) AS Parameters
from LayerHouse lh
	inner join Flock f on lh.LayerHouseID = f.LayerHouseID
								and ((@futureFlocks = 0 and GETDATE() between f.HousingDate_First and IsNull(f.HousingOutDate,'1/1/9999'))
									or (@futureFlocks = 1 and f.HousingDate_First > GETDATE()))
	left join ProductBreed pb on f.ProductBreedID = pb.ProductBreedID
where lh.LocationID = @LocationID
order by lh.LayerHouseName
GO
