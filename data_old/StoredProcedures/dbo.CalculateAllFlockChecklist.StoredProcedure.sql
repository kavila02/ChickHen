if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'CalculateDateOfAction_FlockChecklist' and s.name = 'dbo')
begin
	drop proc CalculateDateOfAction_FlockChecklist
end
GO
create proc CalculateDateOfAction_FlockChecklist
	@FlockChecklistID int
	,@RefreshExisting bit = 0
AS

--Calculate the entire Flock Checklist Date of Action
--When @RefreshExisting is set to 1, all existing dates will be overwritten
--Otherwise it will only calculate null dates

If @RefreshExisting = 1
begin
	update FlockChecklist_Detail
	Set DateOfAction = null
	where FlockChecklistID = @FlockChecklistID
end

--let's start calculations with all the dates from field, since these are fairly constant


--ugh. I hate using dynamic sql. But apparently that's the easiest way to pass in the datepart. It also simplifies the tablename/fieldname so
-- we only have to use the table to define the available options, then calculation should just work
declare @sql table (FlockChecklist_DetailID int, sqlStatement nvarchar(4000), Flag bit)
insert into @sql select d.FlockChecklist_DetailID
	,'
Update d
Set DateOfAction = DATEADD(' + d.TimeFromField_DatePartID + ',d.DateOfAction_TimeFromField,' + fr.TableName + '.' + fr.FieldName + ')
from FlockChecklist_Detail d
	inner join FlockChecklist fc on d.FlockChecklistID = fc.FlockChecklistID
	inner join Flock on fc.FlockID = Flock.FlockID
Where d.FlockChecklist_DetailID = ' + convert(varchar,d.FlockChecklist_DetailID)
	,0
from FlockChecklist_Detail d
	inner join FieldReference fr on d.DateOfAction_FieldReferenceID = fr.FieldReferenceID
Where d.FlockChecklistID = @FlockChecklistID
	And StepOrFieldCalculation = 2
	And DateOfAction is null

declare @currentSQL nvarchar(4000), @currentID int
while exists (Select 1 from @sql where flag = 0)
begin
	select top 1 @currentSQL = SQLStatement, @currentID = FlockChecklist_DetailID from @sql where flag = 0
	
	--update the current step's date of action
	exec(@currentSQL)
	--select @currentSQL

	--update any steps that reference the current one (and subsquently any steps that reference that one, on down the tree)
	exec CalculateDateOfAction_StepUpdate @FlockChecklist_DetailID = @currentID, @NestLevel = 1, @RefreshExisting = @RefreshExisting

	update @sql set Flag = 1 where @currentID = FlockChecklist_DetailID
end





--The following was written before we had a nice recursive stored proc that calculates all of these

/*
--let's loop through and try to update all the steps based on other steps, if the other steps don't have null dates
--we'll give it a good hundred tries or so, then bail. There should only be up to 30 steps, so 100 is excessive, but infinite looping and invalid references
--could be a thing

declare @loop int = 0, @maxTries int = 100
while exists (select 1 from FlockChecklist_Detail
						where @FlockChecklistID = FlockChecklistID
						and StepOrFieldCalculation = 1
						and DateOfAction is null)
		AND @loop < @maxTries
begin
	
	insert into @sql select '
	update d
	set d.DateOfAction = DATEADD(' + d.TimeFromField_DatePartID + ',d.DateOfAction_TimeFromField,d2.DateOfAction)
	from FlockChecklist_Detail d
		inner join FlockChecklist_Detail d2 on d.DateOfAction_FlockChecklist_DetailID = d2.FlockChecklist_DetailID
	where d.FlockChecklistID = ' + convert(varchar,@FlockChecklistID) + '
		And d.StepOrFieldCalculation = 1
		And d.DateOfAction is null'

	from FlockChecklist_Detail d
		inner join FieldReference fr on d.DateOfAction_FieldReferenceID = fr.FieldReferenceID
	where d.FlockChecklistID = @FlockChecklistID
		And d.StepOrFieldCalculation = 1
		And d.DateOfAction is null

	select @currentSQL = ''
	while exists (Select 1 from @sql)
	begin
		select top 1 @currentSQL = SQLStatement from @sql
		--exec(@currentSQL)
		select @currentSQL

		delete from @sql where sqlStatement = @currentSQL
	end

	select @loop = @loop + 1
end
*/