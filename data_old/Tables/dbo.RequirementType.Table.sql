create table RequirementType
(
	RequirementTypeID int primary key identity(1,1)
	,RequirementType nvarchar(255)
	,SortOrder int
)
GO

if not exists (select 1 from RequirementType)
begin
	set identity_insert RequirementType on
	insert into RequirementType (RequirementTypeID, RequirementType, SortOrder)
	select 1, 'Attachment', 1
	union select 2, 'Update', 2
	union select 3, 'Vaccine', 3
	union select 4, 'Other', 4
	set identity_insert RequirementType off
end
