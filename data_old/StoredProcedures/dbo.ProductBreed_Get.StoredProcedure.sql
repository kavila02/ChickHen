if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ProductBreed_Get' and s.name = 'dbo')
begin
	drop proc ProductBreed_Get
end
GO




create proc ProductBreed_Get
@ProductBreedID int = null
,@IncludeNew bit = 1
As

select
	ProductBreedID
	, ProductBreed
	, NumberOfWeeks
	, WeeksHatchToHouse
	, SortOrder
	, IsActive
from ProductBreed
where IsNull(@ProductBreedID,ProductBreedID) = ProductBreedID
union all
select
	ProductBreedID = convert(int,0)
	, ProductBreed = convert(nvarchar(255),null)
	, NumberOfWeeks = convert(numeric(19,2),96)
	, WeeksHatchToHouse = convert(numeric(19,2),null)
	, SortOrder = convert(int,IsNull((Select MAX(SortOrder) + 1 from ProductBreed),1))
	, IsActive = convert(bit,null)
where @IncludeNew = 1
Order by SortOrder
