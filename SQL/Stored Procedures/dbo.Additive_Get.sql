create proc Additive_Get
@IncludeNew bit = 1
As


declare @additiveDisease table (AdditiveID int, DiseaseList nvarchar(500))
insert into @additiveDisease(AdditiveID)
select AdditiveID from Additive 

declare @currentList nvarchar(500), @currentID int
while exists (select 1 from @additiveDisease where DiseaseList is null)
begin
	select top 1 @currentList = '', @currentID = AdditiveID from @additiveDisease where DiseaseList is null
	select @currentList = @currentList + case when @currentList = '' then '' else ', ' end + DiseaseName
	from AdditiveDisease ad
	inner join Disease d on ad.DiseaseID = d.DiseaseID
	where AdditiveID = @currentID
	update @additiveDisease set DiseaseList = @currentList where AdditiveID = @currentID
end


select
	a.AdditiveID
	, Additive
	, ApprovedForColony
	, ApprovedForAviary
	, ApprovedForOrganic
	, IsActive
	, SortOrder
	, case DiseaseList when '' then '{add}' else DiseaseList end as DiseaseList
from Additive a
left outer join @additiveDisease ad on a.AdditiveID = ad.AdditiveID
union all
select
	AdditiveID = convert(int,0)
	, Additive = convert(nvarchar(100),null)
	, ApprovedForColony = convert(bit,null)
	, ApprovedForAviary = convert(bit,null)
	, ApprovedForOrganic = convert(bit,null)
	, IsActive = convert(bit,1)
	, SortOrder = convert(int,IsNull((Select MAX(SortOrder) + 1 from Additive),1))
	, DiseaseList = ''
where @IncludeNew = 1