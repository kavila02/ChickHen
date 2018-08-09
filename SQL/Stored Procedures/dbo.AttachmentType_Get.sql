create proc [dbo].[AttachmentType_Get]
@AttachmentTypeID int = null
,@IncludeNew bit = 1
As

select
	AttachmentTypeID
	, AttachmentType
	, SortOrder
	, IsActive
	, ShowOnScreenID
from AttachmentType
where IsNull(@AttachmentTypeID,AttachmentTypeID) = AttachmentTypeID
union all
select
	AttachmentTypeID = convert(int,0)
	, AttachmentType = convert(nvarchar(255),null)
	, SortOrder = convert(int,IsNull((Select MAX(SortOrder) + 1 from AttachmentType),1))
	, IsActive = convert(bit,1)
	, ShowOnScreenID = convert(smallint,3)
where @IncludeNew = 1
Order by SortOrder