
CREATE proc [dbo].[FlockPulletGrower_Get]
@FlockID int
,@IncludeNew bit = 1
As

declare @defaultAge int
select @defaultAge = DATEDIFF(wk,HatchDate_First,HousingDate_First)
from Flock
where @FlockID = FlockID

select
	fpg.FlockPulletGrowerID
	, fpg.FlockID
	, fpg.PulletGrowerID
	, fpg.ExpectedNumberToHouse
	, dbo.FormatIntComma(fpg.TotalHoused) as TotalHoused
	, fpg.AgeAtHousing
	, fpg.NPIP
	, dbo.FormatIntComma(Capacity) as Capacity
from FlockPulletGrower fpg
left outer join PulletGrower pg on fpg.PulletGrowerID = pg.PulletGrowerID
where @FlockID = FlockID
union all
select
	FlockPulletGrowerID = convert(int,0)
	, FlockID = @FlockID
	, PulletGrowerID = convert(int,null)
	, ExpectedNumberToHouse = convert(int,null)
	, TotalHoused = convert(varchar(20),null)
	, AgeAtHousing = IsNull(@defaultAge,0)
	, NPIP = convert(varchar(50),'')
	, Capacity = convert(varchar(20),'')
where @IncludeNew = 1