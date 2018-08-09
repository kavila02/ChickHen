if not exists (select 1 from sys.tables where name = 'AttachmentType')
begin
create table AttachmentType
(
	AttachmentTypeID int primary key identity(1,1)
	,AttachmentType nvarchar(255)
	,SortOrder int
	,IsActive bit
	,ShowOnScreenID smallint --1 Checklist, 2 Flock, 3 All
)
end
