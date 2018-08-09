if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockChecklist_Detail_GetList' and s.name = 'dbo')
begin
	drop proc FlockChecklist_Detail_GetList
end
GO
create proc FlockChecklist_Detail_GetList
@FlockChecklistID int
,@Checklist_DetailTypeID int = null
,@IncludeNew bit = 1
,@orderByDate bit = 0
As

declare @attachments table (FlockChecklist_DetailID int, attachmentsHtml nvarchar(max))
insert into @attachments (FlockChecklist_DetailID)
select FlockChecklist_DetailID from FlockChecklist_Detail where FlockChecklistID = @FlockChecklistID

declare @AttachmentsHtml nvarchar(max) = '', @currentID int
while exists (select 1 from @attachments where attachmentsHtml is null)
begin
	select top 1 @currentID = FlockChecklist_DetailID, @AttachmentsHtml = '' from @attachments where attachmentsHtml is null
	select  @AttachmentsHtml = @AttachmentsHtml + case when @AttachmentsHtml = '' then '' else '<br/>' end +
	a.FileDescription + ' <a name="Attachments" id="Attachments" href="' + replace(substring(a.Path,2,LEN(a.Path)),'\','/') + '" title="' + a.DisplayName + '" style="padding-right:25px;">'
		+'<i id="AttachmentsIcon" class="center material-icons ng-binging ng-scope">insert_drive_file</i>'
	+'</a>'
	from FlockChecklist_DetailAttachment da 
		inner join Attachment a on da.AttachmentID = a.AttachmentID
	where da.FlockChecklist_DetailID = @currentID

	update @attachments set attachmentsHtml = IsNull(@attachmentsHtml,'') where FlockChecklist_DetailID = @currentID
end

select
	convert(varchar,d.FlockChecklist_DetailID) + '&p=' + convert(varchar,d.FlockChecklistID) As LinkValue
	, d.FlockChecklist_DetailID
	, d.FlockChecklistID
	, StepName
	, StepOrder
	, DateOfAction
	, ActionDescription
	, 'edit' As linkIcon
	, case when exists (select 1 from FlockChecklist_Detail d2 where d.FlockChecklistID = d2.FlockChecklistID and d.Checklist_DetailTypeID = d2.Checklist_DetailTypeID and d2.StepOrder < d.StepOrder) then convert(bit,1) else convert(bit,0) end As showUp
	, case when exists (select 1 from FlockChecklist_Detail d2 where d.FlockChecklistID = d2.FlockChecklistID and d.Checklist_DetailTypeID = d2.Checklist_DetailTypeID and d2.StepOrder > d.StepOrder) then convert(bit,1) else convert(bit,0) end As showDown
	, convert(bit,0) As newRecord
	, 'Checklist for ' 
			+ '<a href="CSB_AngularFormTemplate.html?screenID=Flock&p=' + convert(varchar,f.FlockID) + '" class="black underline" >' + rtrim(f.FlockName) + '</a>'
			As listTitle
	, d.CompletedDate
	, case when @orderByDate = 1 then DateOfAction else convert(date,null) end as OrderDate
	, attachmentsHtml
	, Checklist_DetailTypeID
from FlockChecklist_Detail d
	inner join FlockChecklist t on d.FlockChecklistID = t.FlockChecklistID
	inner join Flock f on t.FlockID = f.FlockID
	left outer join @attachments a on d.FlockChecklist_DetailID = a.FlockChecklist_DetailID
where d.FlockChecklistID = @FlockChecklistID
and @Checklist_DetailTypeID = Checklist_DetailTypeID

union all
select
	'0&p=' + convert(varchar,@FlockChecklistID) As LinkValue
	,convert(int,0) As FlockChecklist_DetailID
	,@FlockChecklistID As FlockChecklistID
	,'{add new}' As StepName
	,convert(int,IsNull((Select MAX(StepOrder) + 1 from FlockChecklist_Detail where FlockChecklistID = @FlockChecklistID and IsNull(@Checklist_DetailTypeID,Checklist_DetailTypeID) = Checklist_DetailTypeID),1)) As StepOrder
	,convert(date,null) As DateOfAction
	,'' As ActionDescription
	,'control_point' As linkIcon
	, convert(bit,0) As showUp
	, convert(bit,0) As showDown
	, convert(bit,1) As newRecord
	, (select 'Checklist for ' 
			+ '<a href="CSB_AngularFormTemplate.html?screenID=Flock&p=' + convert(varchar,f.FlockID) + '" class="black underline" >' + rtrim(f.FlockName) + '</a>'
			from FlockChecklist t inner join Flock f on t.FlockID = f.FlockID where t.FlockChecklistID = @FlockChecklistID) As listTitle
	, convert(date,null) As CompletedDate
	, convert(date,null) As OrderDate
	, NULL as AttachmentsHtml
	, @Checklist_DetailTypeID as Checklist_DetailTypeID
where @includeNew = 1
and IsNull(@Checklist_DetailTypeID,'') <> ''
order by OrderDate, StepOrder