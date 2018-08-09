create proc [dbo].[AttachmentType_Lookup]
	@IncludeBlank bit = 1
	,@IncludeAll bit = 0
As

select AttachmentType,AttachmentTypeID,SortOrder
from AttachmentType
where IsActive = 1

union all
select '','',0
where @IncludeBlank = 1

union all
select 'All','',0
where @IncludeAll = 1

Order by SortOrder