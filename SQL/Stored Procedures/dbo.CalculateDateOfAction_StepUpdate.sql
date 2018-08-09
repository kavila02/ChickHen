create proc CalculateDateOfAction_StepUpdate
	@FlockChecklist_DetailID int
	,@RefreshExisting bit = 1
	,@NestLevel int = 1
AS

--There are currently only 30 steps, so if this is looping more than 100 levels something is wrong and we should bail
declare @MAXNESTLEVEL int = 100

if @NestLevel >= @MAXNESTLEVEL
begin
	return
end


--The passed in FlockChecklist_DetailID is the one that was just updated
--So find any details that reference that ID in their Date of Action

--update them to the current detail's new date

declare @sql table (FlockChecklist_DetailID int, sqlStatement nvarchar(4000), Flag bit, EndDate bit)
insert into @sql select d.FlockChecklist_DetailID
	,'update FlockChecklist_Detail
Set DateOfAction = DATEADD(' + d.TimeFromStep_DatePartID + ',' + convert(varchar,d.DateOfAction_TimeFromStep) + ',''' + convert(varchar,(select DateOfAction from FlockChecklist_Detail where FlockChecklist_DetailID = @FlockChecklist_DetailID)) + ''')
Where FlockChecklist_DetailID = ' + convert(varchar,d.FlockChecklist_DetailID)
	,0
	,0
from FlockChecklist_Detail d
Where DateOfAction_FlockChecklist_DetailID = @FlockChecklist_DetailID
and StepOrFieldCalculation = 1
and (DateOfAction is null or @RefreshExisting = 1)
insert into @sql select d.FlockChecklist_DetailID
	,'update FlockChecklist_Detail
Set DateOfAction_EndDate = DATEADD(' + d.TimeFromStep_DatePartID_EndDate + ',' + convert(varchar,d.DateOfAction_TimeFromStep_EndDate) + ',''' + convert(varchar,(select DateOfAction_EndDate from FlockChecklist_Detail where FlockChecklist_DetailID = @FlockChecklist_DetailID)) + ''')
Where FlockChecklist_DetailID = ' + convert(varchar,d.FlockChecklist_DetailID)
	,0
	,1
from FlockChecklist_Detail d
Where DateOfAction_FlockChecklist_DetailID = @FlockChecklist_DetailID
and StepOrFieldCalculation_EndDate = 1
and (DateOfAction_EndDate is null or @RefreshExisting = 1)


declare @currentSQL nvarchar(4000), @currentID int, @newNestLevel int, @currentType bit
while exists (Select 1 from @sql where flag = 0)
begin
	select top 1 @currentSQL = SQLStatement, @currentID = FlockChecklist_DetailID, @currentType = EndDate from @sql where flag = 0
	
	--update the current step's date of action
	exec(@currentSQL)
	--select @currentSQL

	--update any steps that reference the current one (and subsquently any steps that reference that one, on down the tree)
	select @newNestLevel = @NestLevel + 1

	--Now go through and call each date that was just updated into the CalculateDateOfAction_StepUpdate so any references to them get updated
	exec CalculateDateOfAction_StepUpdate @FlockChecklist_DetailID = @currentID, @RefreshExisting = @RefreshExisting, @NestLevel = @newNestLevel

	update @sql set Flag = 1 where @currentID = FlockChecklist_DetailID and @currentType = EndDate
end




