if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockChecklist_Detail_Sort' and s.name = 'dbo')
begin
	drop proc FlockChecklist_Detail_Sort
end
GO

create proc FlockChecklist_Detail_Sort
	@I_vFlockChecklist_DetailID int
	,@I_vSortDirection smallint --1=positive, -1=negative. Please remember that a positive move is down on a list, a negative move is up on a list
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

declare @switchFlockChecklist_DetailID int, @FlockChecklistID int, @currentStepOrder int, @Checklist_DetailTypeID int
select @FlockChecklistID = FlockChecklistID
	,@currentStepOrder = StepOrder
	,@Checklist_DetailTypeID = Checklist_DetailTypeID
from FlockChecklist_Detail
where FlockChecklist_DetailID = @I_vFlockChecklist_DetailID

--Get the next one up or down
If @I_vSortDirection > 0
begin
	select top 1 @switchFlockChecklist_DetailID = FlockChecklist_DetailID
		from FlockChecklist_Detail
		where FlockChecklistID = @FlockChecklistID
			and Checklist_DetailTypeID = @Checklist_DetailTypeID
			and StepOrder > @currentStepOrder
		order by StepOrder
end
else if @I_vSortDirection < 0
begin
	select top 1 @switchFlockChecklist_DetailID = FlockChecklist_DetailID
		from FlockChecklist_Detail
		where FlockChecklistID = @FlockChecklistID
			and Checklist_DetailTypeID = @Checklist_DetailTypeID
			and StepOrder < @currentStepOrder
		order by StepOrder desc
end

--switch the Sort Orders
if @switchFlockChecklist_DetailID is not null
begin
	declare @switchStepOrder int
	select @switchStepOrder = StepOrder
	from FlockChecklist_Detail
	where FlockChecklist_DetailID = @switchFlockChecklist_DetailID

	update FlockChecklist_Detail
	set StepOrder = @switchStepOrder
	where FlockChecklist_DetailID = @I_vFlockChecklist_DetailID

	update FlockChecklist_Detail
	set StepOrder = @currentStepOrder
	where FlockChecklist_DetailID = @switchFlockChecklist_DetailID

end