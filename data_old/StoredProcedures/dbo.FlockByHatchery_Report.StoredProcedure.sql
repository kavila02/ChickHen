if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockByHatchery_Report' and s.name = 'dbo')
begin
	drop proc FlockByHatchery_Report
end
GO
create proc FlockByHatchery_Report
	@HatcheryID int = null
	,@startdate date = null
	,@enddate date = null
As

if @startdate is null or @startdate = ''
	set @startdate = '1/1/1900'

if @enddate is null or @enddate = ''
	set @enddate = '1/1/9999'

select 
	FlockID
	,HatchDate_First
	,OrderNumber
	,ProductBreed
	,NumberChicksOrdered
	,HousingDate_First
	,FlockName
	,Hatchery
from Flock f
left outer join ProductBreed pb on f.ProductBreedID = pb.ProductBreedID
inner join Hatchery h on f.HatcheryID = h.HatcheryID
where HousingDate_First between @startdate and @enddate
and f.HatcheryID = @HatcheryID