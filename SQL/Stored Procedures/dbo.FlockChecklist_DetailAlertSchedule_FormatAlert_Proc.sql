create proc FlockChecklist_DetailAlertSchedule_FormatAlert_Proc
	@alert nvarchar(max) output
	,@FlockChecklist_DetailAlertScheduleID int
AS

declare @fieldList table (FieldReferenceID int, TableName varchar(50), FieldName varchar(50), DateField bit)
insert into @fieldList
select FieldReferenceID, TableName, FieldName, DateField
from FieldReference
where TableName > ''
and AlertField = 1

declare @currentID int, @sql nvarchar(2000)
while exists (select 1 from @fieldList)
begin
	select top 1 @currentID = FieldReferenceID from @fieldList

	select @sql = 'select @alert = REPLACE(''' + @alert + ''',''{{' + FieldName + '}}'',rtrim(IsNull('
					+ case when DateField = 1 then 'convert(varchar,' else '' end
					+ case when TableName = 'FlockChecklist_DetailAlertSchedule' then 's.'
						when TableName = 'FlockChecklist_Detail' then 'd.'
						when TableName = 'Flock' then 'f.'
					else '' end
					+ FieldName 
					+ case when DateField = 1 then ',101)' else '' end
					+ ','''')))
		from FlockChecklist_DetailAlertSchedule s
		inner join FlockChecklist_Detail d on s.FlockChecklist_DetailID = d.FlockChecklist_DetailID
		inner join FlockChecklist fc on d.FlockChecklistID = fc.FlockChecklistID
		inner join Flock f on fc.FlockID = f.FlockID
		cross join Message_DefaultValues m
		inner join AlertTemplate t on s.AlertTemplateID = t.AlertTemplateID
	where s.FlockChecklist_DetailAlertScheduleID = ' + convert(varchar,@FlockChecklist_DetailAlertScheduleID)

	from @fieldList
	where @currentID = FieldReferenceID
	
	exec sp_executesql @sql, N'@alert nvarchar(max) output', @alert = @alert output
	
	delete from @fieldList where @currentID = FieldReferenceID
end

select 
	@alert =
		REPLACE(REPLACE(@alert
			,'{{FlockLink}}','<a href="' + rtrim(m.URLPrefix) + 'Form.html?screenID=Flock&p=' + convert(varchar,f.FlockID) + '">' + rtrim(f.FlockName) + '</a>')
			,'{{StepLink}}','<a href="' + rtrim(m.URLPrefix) + 'Form.html?screenID=FlockChecklist_Detail_Simple&p=' + convert(varchar,d.FlockChecklist_DetailID) + '">' + rtrim(d.StepName) + '</a>')
		from FlockChecklist_DetailAlertSchedule s
		inner join FlockChecklist_Detail d on s.FlockChecklist_DetailID = d.FlockChecklist_DetailID
		inner join FlockChecklist fc on d.FlockChecklistID = fc.FlockChecklistID
		inner join Flock f on fc.FlockID = f.FlockID
		cross join Message_DefaultValues m
	where s.FlockChecklist_DetailAlertScheduleID = @FlockChecklist_DetailAlertScheduleID