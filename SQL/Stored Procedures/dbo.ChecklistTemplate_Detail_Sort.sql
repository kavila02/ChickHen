
create proc ChecklistTemplate_Detail_Sort
	@I_vChecklistTemplate_DetailID int
	,@I_vSortDirection smallint --1=positive, -1=negative. Please remember that a positive move is down on a list, a negative move is up on a list
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

declare @switchChecklistTemplate_DetailID int, @ChecklistTemplateID int, @currentStepOrder int, @Checklist_DetailTypeID int
select @ChecklistTemplateID = ChecklistTemplateID
	,@currentStepOrder = StepOrder
	,@Checklist_DetailTypeID = Checklist_DetailTypeID
from ChecklistTemplate_Detail
where ChecklistTemplate_DetailID = @I_vChecklistTemplate_DetailID

--Get the next one up or down
If @I_vSortDirection > 0
begin
	select top 1 @switchChecklistTemplate_DetailID = ChecklistTemplate_DetailID
		from ChecklistTemplate_Detail
		where ChecklistTemplateID = @ChecklistTemplateID
			and Checklist_DetailTypeID = @Checklist_DetailTypeID
			and StepOrder > @currentStepOrder
		order by StepOrder
end
else if @I_vSortDirection < 0
begin
	select top 1 @switchChecklistTemplate_DetailID = ChecklistTemplate_DetailID
		from ChecklistTemplate_Detail
		where ChecklistTemplateID = @ChecklistTemplateID
			and Checklist_DetailTypeID = @Checklist_DetailTypeID
			and StepOrder < @currentStepOrder
		order by StepOrder desc
end

--switch the Sort Orders
if @switchChecklistTemplate_DetailID is not null
begin
	declare @switchStepOrder int
	select @switchStepOrder = StepOrder
	from ChecklistTemplate_Detail
	where ChecklistTemplate_DetailID = @switchChecklistTemplate_DetailID

	update ChecklistTemplate_Detail
	set StepOrder = @switchStepOrder
	where ChecklistTemplate_DetailID = @I_vChecklistTemplate_DetailID

	update ChecklistTemplate_Detail
	set StepOrder = @currentStepOrder
	where ChecklistTemplate_DetailID = @switchChecklistTemplate_DetailID

end