



create proc FlockOrderCalculator
@FlockID int = null
AS
declare @footer varchar(500) = '<span>Calculated Hatch Date = Current Hatch Date + Number of Weeks - Weeks from Hatch to House</span><br/>
<span>Calculated House Date = Current Hatch Date + Number of Weeks</span><br/>
<span>Calculated Out Date = Calculated Hatch Date + Number of Weeks</span><br/>'

If @FlockID is null
begin
	select
		convert(date,GETDATE()) as HatchDate_First
		,convert(date,GETDATE()) as HousingDate_Average
		,convert(date,GETDATE()) as HousingOutDate

		,convert(int,null) as ProductBreedID
		,convert(numeric(19,2),96) as NumberOfWeeks
		,convert(numeric(19,2),18) as WeeksHatchToHouse

		,DATEADD(wk,78,convert(date,GETDATE())) as CalculatedHatchDate
		,DATEADD(wk,96,convert(date,GETDATE())) as CalculatedHouseDate
		,DATEADD(wk,174,convert(date,GETDATE())) as CalculatedOutDate

		,'' as FlockName
		,@footer as Footer
end
else
begin
	select
		f.HatchDate_First
		,f.HousingDate_Average
		,f.HousingOutDate

		,f.ProductBreedID
		,IsNull(pb.NumberOfWeeks,96) as NumberOfWeeks
		,IsNull(pb.WeeksHatchToHouse,18) as WeeksHatchToHouse

		--Calc Hatch Date = Current Hatch + Weeks - HatchToHouse
		,DATEADD(wk,IsNull(pb.NumberOfWeeks,96)-IsNull(pb.WeeksHatchToHouse,18),f.HatchDate_First) as CalculatedHatchDate

		--Calc House Date = Current Hatch + Weeks
		,DATEADD(wk,IsNull(pb.NumberOfWeeks,96),f.HatchDate_First) as CalculatedHouseDate

		--Calc Out Date = Calc Hatch Date + Weeks = Current Hatch + Weeks - HatchToHouse + Weeks = Current Hatch + 2Weeks - HatchToHouse
		,DATEADD(wk,(2*IsNull(pb.NumberOfWeeks,96))-IsNull(pb.WeeksHatchToHouse,18),f.HatchDate_First) as CalculatedOutDate

		,f.FlockName
		,@footer as Footer
	from Flock f
	left outer join ProductBreed pb on f.ProductBreedID = pb.ProductBreedID
	where FlockID = @FlockID
end