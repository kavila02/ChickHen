if exists (Select 1 from sys.objects where name = 'HomePage_LocationCard' and type='P')
begin
	drop proc HomePage_LocationCard
end
go

create proc HomePage_LocationCard
@LocationID int
,@futureFlocks bit = 0
as

declare @PEQAPNumbers nvarchar(2000) = ''
select @PEQAPNumbers = @PEQAPNumbers + IsNull(case when @PEQAPNumbers = '' then '' else ', ' end
			+ PEQAPNumber,'')
			from LayerHouse
			where LocationID = @LocationID

declare @FarmBirdCapacity int, @CurrentBirdTotal int

select @FarmBirdCapacity = SUM(BirdCapacity)
from LayerHouse where LocationID = @LocationID

select @CurrentBirdTotal = SUM(f.TotalChicksPlaced)
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
,@FarmBirdCapacity as FarmBirdCapacity
,@CurrentBirdTotal as CurrentBirdTotal
from Location l
where l.LocationID = @LocationID