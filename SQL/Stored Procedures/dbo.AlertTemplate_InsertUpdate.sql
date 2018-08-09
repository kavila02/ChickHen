
create proc AlertTemplate_InsertUpdate
	@I_vAlertTemplateID int
	,@I_valertBody nvarchar(max) = ''
	,@I_vAlertName nvarchar(100) = ''
	,@I_vSortOrder smallint = null
	,@I_vIsActive bit = 1
	,@I_valertSubject nvarchar(100) = ''
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vAlertTemplateID = 0
begin
	declare @AlertTemplateID table (AlertTemplateID int)
	insert into AlertTemplate (
		
		alertBody
		, AlertName
		, SortOrder
		, IsActive
		, alertSubject
	)
	output inserted.AlertTemplateID into @AlertTemplateID(AlertTemplateID)
	select
		
		@I_valertBody
		,@I_vAlertName
		,@I_vSortOrder
		,@I_vIsActive
		,@I_valertSubject
	select top 1 @I_vAlertTemplateID = AlertTemplateID, @iRowID = AlertTemplateID from @AlertTemplateID
end
else
begin
	update AlertTemplate
	set
		
		alertBody = @I_valertBody
		,AlertName = @I_vAlertName
		,SortOrder = @I_vSortOrder
		,IsActive = @I_vIsActive
		,alertSubject = @I_valertSubject
	where @I_vAlertTemplateID = AlertTemplateID
	select @iRowID = @I_vAlertTemplateID
end

select @I_vAlertTemplateID as ID,'forward' As referenceType