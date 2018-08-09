if exists (select 1 from sys.objects f inner join sys.schemas s on f.schema_id = s.schema_id where f.type = 'FN' and f.name = 'FlockChecklist_DetailAlertSchedule_FormatAlert' and s.name = 'dbo')
begin
	drop function FlockChecklist_DetailAlertSchedule_FormatAlert
end
GO
create FUNCTION FlockChecklist_DetailAlertSchedule_FormatAlert (
	@alert nvarchar(max)
	,@FlockChecklist_DetailAlertScheduleID int
)
RETURNS varchar(max)
AS
BEGIN
	RETURN (
	select REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@alert
						,'{{StepName}}',rtrim(d.StepName))
						,'{{AlertDescription}}',rtrim(s.AlertDescription))
						,'{{DateOfAction}}',rtrim(convert(varchar,d.DateOfAction,101)))
						,'{{FlockLink}}','<a href="' + rtrim(m.URLPrefix) + 'CSB_AngularFormTemplate.html?screenID=Flock&p=' + convert(varchar,f.FlockID) + '">' + rtrim(f.FlockName) + '</a>')
						,'{{StepLink}}','<a href="' + rtrim(m.URLPrefix) + 'CSB_AngularFormTemplate.html?screenID=FlockChecklist_Detail_Simple&p=' + convert(varchar,d.FlockChecklist_DetailID) + '">' + rtrim(d.StepName) + '</a>')
		from FlockChecklist_DetailAlertSchedule s
		inner join FlockChecklist_Detail d on s.FlockChecklist_DetailID = d.FlockChecklist_DetailID
		inner join FlockChecklist fc on d.FlockChecklistID = fc.FlockChecklistID
		inner join Flock f on fc.FlockID = f.FlockID
		cross join Message_DefaultValues m
		inner join AlertTemplate t on s.AlertTemplateID = t.AlertTemplateID
	where s.FlockChecklist_DetailAlertScheduleID = @FlockChecklist_DetailAlertScheduleID
	)
END


