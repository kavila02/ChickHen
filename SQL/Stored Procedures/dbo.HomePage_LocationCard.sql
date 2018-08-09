
CREATE proc [dbo].[HomePage_LocationCard]
@LocationID int
,@futureFlocks bit = 0
as

declare @PEQAPNumbers nvarchar(2000) = ''
select @PEQAPNumbers = @PEQAPNumbers + IsNull(case when @PEQAPNumbers = '' then '' else ', ' end
			+ PEQAPNumber,'')
			from LayerHouse
			where LocationID = @LocationID

declare @FarmBirdCapacity int, @CurrentBirdTotal int

select @FarmBirdCapacity = SUM(IsNull(BirdsPerHouse,0))
from LayerHouse where LocationID = @LocationID

select @CurrentBirdTotal = SUM(IsNull(f.TotalChicksPlaced,0))
from Flock f
inner join LayerHouse lh on f.LayerHouseID = lh.LayerHouseID
where lh.LocationID = @LocationID
and ((@futureFlocks = 0 and GETDATE() between f.HousingDate_First and f.HousingOutDate)
									or (@futureFlocks = 1 and f.HousingDate_First > GETDATE()))

select
l.Location
,rtrim(l.USDAPlantNumber1) + '; ' + rtrim(l.USDAPlantNumber2) as USDAPlantNumber
,l.PDAPremiseID
,l.PDANumber
,@PEQAPNumbers as PEQAPNumbers
,dbo.FormatIntComma(@FarmBirdCapacity) as FarmBirdCapacity
,dbo.FormatIntComma(@CurrentBirdTotal) as CurrentBirdTotal
,@LocationID as LocationID
from Location l
where l.LocationID = @LocationID