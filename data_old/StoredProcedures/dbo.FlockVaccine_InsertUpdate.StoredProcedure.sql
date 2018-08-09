if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockVaccine_InsertUpdate' and s.name = 'dbo')
begin
	drop proc FlockVaccine_InsertUpdate
end
GO

create proc FlockVaccine_InsertUpdate
	@I_vFlockVaccineID int
	,@I_vFlockID int
	,@I_vVaccineID int = null
	,@I_vVaccineStatusID int = null
	,@I_vFlockVaccineNotes nvarchar(4000) = ''
	,@I_vScheduledDate date = null
	,@I_vCompletedDate date = null
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vFlockVaccineID = 0
begin
	insert into FlockVaccine (
		
		FlockID
		, VaccineID
		, VaccineStatusID
		, FlockVaccineNotes
		, ScheduledDate
		, CompletedDate
	)
	select
		
		@I_vFlockID
		,@I_vVaccineID
		,@I_vVaccineStatusID
		,@I_vFlockVaccineNotes
		,@I_vScheduledDate
		,@I_vCompletedDate

	select @I_vFlockVaccineID = SCOPE_IDENTITY()
end
else
begin
	update FlockVaccine
	set
		
		FlockID = @I_vFlockID
		,VaccineID = @I_vVaccineID
		,VaccineStatusID = @I_vVaccineStatusID
		,FlockVaccineNotes = @I_vFlockVaccineNotes
		,ScheduledDate = @I_vScheduledDate
		,CompletedDate = @I_vCompletedDate
	where @I_vFlockVaccineID = FlockVaccineID
end

select @I_vFlockVaccineID as ID,'forward' As referenceType