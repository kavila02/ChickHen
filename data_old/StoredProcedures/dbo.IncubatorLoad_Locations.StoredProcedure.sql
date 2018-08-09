if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'IncubatorLoad_Locations' and s.name = 'dbo')
begin
	drop proc IncubatorLoad_Locations
end
GO
create proc IncubatorLoad_Locations
AS

select convert(int,1) As SortOrder, convert(int,23) As LocationNumber, convert(int,1) As RowNumber, convert(varchar(50),'incubatorColumn') as className
union all select 2,22,1,'incubatorColumn'
union all select 3,11,1,'incubatorColumn'
union all select 4,10,1,'incubatorColumn'
union all select 5,0,1, ' incubatorColumn  incubatorColumnEmpty'
union all select 6,24,2,'incubatorColumn'
union all select 7,21,2,'incubatorColumn'
union all select 8,12,2,'incubatorColumn'
union all select 9,9,2,'incubatorColumn'
union all select 10,1,2,'incubatorColumn'
union all select 11,25,3,'incubatorColumn'
union all select 12,20,3,'incubatorColumn'
union all select 13,13,3,'incubatorColumn'
union all select 14,8,3,'incubatorColumn'
union all select 15,2,3,'incubatorColumn'
--FANS--
union all select 16,0,4,'incubatorColumn incubatorColumnEmpty'
union all select 17,0,4,'incubatorColumn incubatorColumnEmpty'
union all select 18,-1,4,'incubatorColumn incubatorColumnEmpty incubatorColumnFans'
union all select 19,0,4,'incubatorColumn incubatorColumnEmpty'
union all select 20,0,4,'incubatorColumn incubatorColumnEmpty'
--------
union all select 21,26,5,'incubatorColumn'
union all select 22,19,5,'incubatorColumn'
union all select 23,14,5,'incubatorColumn'
union all select 24,7,5,'incubatorColumn'
union all select 25,3,5,'incubatorColumn'
union all select 26,27,6,'incubatorColumn'
union all select 27,18,6,'incubatorColumn'
union all select 28,15,6,'incubatorColumn'
union all select 29,6,6,'incubatorColumn'
union all select 30,4,6,'incubatorColumn'
union all select 31,28,7,'incubatorColumn'
union all select 32,17,7,'incubatorColumn'
union all select 33,16,7,'incubatorColumn'
union all select 34,5,7,'incubatorColumn'
union all select 35,0,7,'incubatorColumn incubatorColumnEmpty'
order by SortOrder