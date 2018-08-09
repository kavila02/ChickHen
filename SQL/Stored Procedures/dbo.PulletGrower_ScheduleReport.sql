create proc PulletGrower_ScheduleReport
	@reportDate date = null
AS
select @reportDate = IsNull(NullIf(@reportDate,''),GETDATE())

declare @recentFlocks table (PulletGrowerID int, PreviousHousingDate date)
insert into @recentFlocks
select
	pg.PulletGrowerID
	,MAX(f.HousingDate_Last)
from PulletGrower pg
	inner join FlockPulletGrower fpg on pg.PulletGrowerID = fpg.PulletGrowerID
	inner join Flock f on fpg.FlockID = f.FlockID
where f.HousingDate_Last < @reportDate
group by pg.PulletGrowerID

declare @nextFlocks table (PulletGrowerID int, NextHatchDate date)
insert into @nextFlocks
select
	pg.PulletGrowerID
	,MIN(f.HatchDate_First)
from PulletGrower pg
	inner join FlockPulletGrower fpg on pg.PulletGrowerID = fpg.PulletGrowerID
	inner join Flock f on fpg.FlockID = f.FlockID
where @reportDate < f.HatchDate_First
group by pg.PulletGrowerID

select
	pg.PulletGrower
	,pg.Capacity
	,fpg.TotalHoused
	,f.FlockName

	,rf.PreviousHousingDate
	,nf.NextHatchDate
from PulletGrower pg
left outer join FlockPulletGrower fpg 
	inner join Flock f on fpg.FlockID = f.FlockID and @reportDate between f.HatchDate_First and f.HousingDate_Last
on pg.PulletGrowerID = fpg.PulletGrowerID
left outer join @recentFlocks rf on pg.PulletGrowerID = rf.PulletGrowerID
left outer join @nextFlocks nf on pg.PulletGrowerID = nf.PulletGrowerID
order by pg.SortOrder