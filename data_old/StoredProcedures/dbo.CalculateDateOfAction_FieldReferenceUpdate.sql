create proc CalculateDateOfAction_FieldReferenceUpdate
	@TableName nvarchar(255)
	,@FieldName nvarchar(255)
	,@TableID int
	,@RefreshExisting bit = 1
AS

--If @RefreshExisting = 0, only update null DateOfAction
--Not sure why we would need that, but it's there anyway

--@TableName.@FieldName at row @TableID was updated. Find all references to this and update their DateOfAction


declare @sql table (FlockChecklist_DetailID int, sqlStatement nvarchar(4000), flag bit, EndDate bit)
insert into @sql select 
	d.FlockChecklist_DetailID
	, '
Update d
Set DateOfAction = DATEADD(' + d.TimeFromField_DatePartID + ',d.DateOfAction_TimeFromField,' + fr.TableName + '.' + fr.FieldName + ')
from FlockChecklist_Detail d
	inner join FlockChecklist fc on d.FlockChecklistID = fc.FlockChecklistID
	inner join Flock on fc.FlockID = Flock.FlockID
Where FlockChecklist_DetailID = ' + convert(varchar,d.FlockChecklist_DetailID)
	,0
	,0
from FlockChecklist_Detail d
	inner join FlockChecklist f on d.FlockChecklistID = f.FlockChecklistID
	left outer join ChecklistTemplate ct on f.ChecklistTemplateID = ct.ChecklistTemplateID
	left outer join ChecklistTemplate_Detail ctd on d.ChecklistTemplate_DetailID = ctd.ChecklistTemplate_DetailID
	inner join FieldReference fr on d.DateOfAction_FieldReferenceID = fr.FieldReferenceID
Where d.StepOrFieldCalculation = 2
	And (d.DateOfAction is null or @RefreshExisting = 1)
	and fr.TableName = @TableName
	and fr.FieldName = @FieldName
	and case when @TableName = 'Flock' and f.FlockID = @TableID then 1
			when @TableName = 'ChecklistTemplate' and ct.ChecklistTemplateID = @TableID then 1
			when @TableName = 'ChecklistTemplate_Detail' and ctd.ChecklistTemplate_DetailID = @TableID then 1
			else 0 end = 1

insert into @sql select 
	d.FlockChecklist_DetailID
	, '
Update d
Set DateOfAction_EndDate = DATEADD(' + d.TimeFromField_DatePartID_EndDate + ',d.DateOfAction_TimeFromField_EndDate,' + fr.TableName + '.' + fr.FieldName + ')
from FlockChecklist_Detail d
	inner join FlockChecklist fc on d.FlockChecklistID = fc.FlockChecklistID
	inner join Flock on fc.FlockID = Flock.FlockID
Where FlockChecklist_DetailID = ' + convert(varchar,d.FlockChecklist_DetailID)
	,0
	,1
from FlockChecklist_Detail d
	inner join FlockChecklist f on d.FlockChecklistID = f.FlockChecklistID
	left outer join ChecklistTemplate ct on f.ChecklistTemplateID = ct.ChecklistTemplateID
	left outer join ChecklistTemplate_Detail ctd on d.ChecklistTemplate_DetailID = ctd.ChecklistTemplate_DetailID
	inner join FieldReference fr on d.DateOfAction_FieldReferenceID_EndDate = fr.FieldReferenceID
Where d.StepOrFieldCalculation_EndDate = 2
	And (d.DateOfAction_EndDate is null or @RefreshExisting = 1)
	and fr.TableName = @TableName
	and fr.FieldName = @FieldName
	and case when @TableName = 'Flock' and f.FlockID = @TableID then 1
			when @TableName = 'ChecklistTemplate' and ct.ChecklistTemplateID = @TableID then 1
			when @TableName = 'ChecklistTemplate_Detail' and ctd.ChecklistTemplate_DetailID = @TableID then 1
			else 0 end = 1

declare @currentSQL nvarchar(4000), @currentID int, @currentType bit
while exists (Select 1 from @sql where Flag = 0)
begin
	select top 1 @currentSQL = SQLStatement, @currentID = FlockChecklist_DetailID, @currentType = EndDate from @sql where Flag = 0

	--update the current step's date of action
	exec(@currentSQL)
	--select @currentSQL

	--update any steps that reference the current one (and subsquently any steps that reference that one, on down the tree)
	exec CalculateDateOfAction_StepUpdate @FlockChecklist_DetailID = @currentID, @NestLevel = 1

	update @sql set Flag = 1 where FlockChecklist_DetailID = @currentID and @currentType = EndDate
end

