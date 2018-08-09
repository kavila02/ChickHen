CREATE proc [dbo].[FlockChecklistCalendar_FilterContent_Get] 
	@UserName nvarchar(255) = ''
AS

select rtrim(TableName) + '.' + rtrim(FieldName) as linkType, friendlyName as displayName, convert(bit,1) as Show
	from FieldReference where DateField = 1 and IncludeInCalendar = 1