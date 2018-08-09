create proc AdditiveDisease_Get
@AdditiveID int = null
,@IncludeNew bit = 1
As

select
	AdditiveDiseaseID
	, ad.AdditiveID
	, DiseaseID
	, 'Diseases for ' + rtrim(Additive) as heading
from AdditiveDisease ad
inner join Additive a on ad.AdditiveID = a.AdditiveID
where @AdditiveID = a.AdditiveID
union all
select
	AdditiveDiseaseID = convert(int,0)
	, AdditiveID = @AdditiveID
	, DiseaseID = convert(int,null)
	, 'Diseases for ' + rtrim(Additive) as heading
from Additive where AdditiveID = @AdditiveID
and @IncludeNew = 1