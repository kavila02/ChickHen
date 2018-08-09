if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_Detail_GetList' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_Detail_GetList
end
GO
create proc ChecklistTemplate_Detail_GetList
@ChecklistTemplateID int
,@Checklist_DetailTypeID int = null
,@IncludeNew bit = 1
As

select
	convert(varchar,ChecklistTemplate_DetailID) + '&p=' + convert(varchar,d.ChecklistTemplateID) As LinkValue
	, ChecklistTemplate_DetailID
	, d.ChecklistTemplateID
	, StepName
	, StepOrder
	, ActionDescription
	, 'edit' As linkIcon
	, case when exists (select 1 from ChecklistTemplate_Detail d2 where d.ChecklistTemplateID = d2.ChecklistTemplateID and d.Checklist_DetailTypeID = d2.Checklist_DetailTypeID and d2.StepOrder < d.StepOrder) then convert(bit,1) else convert(bit,0) end As showUp
	, case when exists (select 1 from ChecklistTemplate_Detail d2 where d.ChecklistTemplateID = d2.ChecklistTemplateID and d.Checklist_DetailTypeID = d2.Checklist_DetailTypeID and d2.StepOrder > d.StepOrder) then convert(bit,1) else convert(bit,0) end As showDown
	, convert(bit,0) As newRecord
	, 'Checklist Template Detail - ' + t.TemplateName As listTitle
	, Checklist_DetailTypeID
from ChecklistTemplate_Detail d
	inner join ChecklistTemplate t on d.ChecklistTemplateID = t.ChecklistTemplateID
where d.ChecklistTemplateID = @ChecklistTemplateID
and Checklist_DetailTypeID = @Checklist_DetailTypeID
union all
select
	'0&p=' + convert(varchar,@ChecklistTemplateID) As LinkValue
	,convert(int,0) As ChecklistTemplate_DetailID
	,@ChecklistTemplateID As ChecklistTemplateID
	,'{add new}' As StepName
	,convert(int,IsNull((Select MAX(StepOrder) + 1 from ChecklistTemplate_Detail where ChecklistTemplateID = @ChecklistTemplateID and IsNull(@Checklist_DetailTypeID,Checklist_DetailTypeID) = Checklist_DetailTypeID),1)) As StepOrder
	,'' As ActionDescription
	,'control_point' As linkIcon
	, convert(bit,0) As showUp
	, convert(bit,0) As showDown
	, convert(bit,1) As newRecord
	, 'Checklist Template Detail - ' + (select TemplateName from ChecklistTemplate where ChecklistTemplateID = @ChecklistTemplateID) As listTitle
	, @Checklist_DetailTypeID as ChecklistDetail_TypeID
where IsNull(@Checklist_DetailTypeID,'') <> ''
order by StepOrder