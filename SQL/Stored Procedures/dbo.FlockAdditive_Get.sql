create proc FlockAdditive_Get
@FlockID int = null
,@FlockAdditiveID int = null
,@IncludeNew bit = 1
As

select
	FlockAdditiveID
	, FlockID
	, AdditiveID
	, AdditiveStatusID
	, FlockAdditiveNotes
	, StartDate
	, EndDate
	, convert(bit,0) as newRecord
from FlockAdditive
where IsNull(@FlockID,FlockID) = FlockID
and IsNull(@FlockAdditiveID,FlockAdditiveID) = FlockAdditiveID
union all
select
	FlockAdditiveID = convert(int,0)
	, FlockID = @FlockID
	, AdditiveID = convert(int,null)
	, AdditiveStatusID = convert(int,null)
	, FlockAdditiveNotes = convert(nvarchar(255),null)
	, StartDate = convert(date,null)
	, EndDate = convert(date,null)
	, convert(bit,1) as newRecord
where @IncludeNew = 1