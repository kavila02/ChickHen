if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockPulletGrower_InsertUpdate' and s.name = 'dbo')
begin
	drop proc FlockPulletGrower_InsertUpdate
end
GO

create proc FlockPulletGrower_InsertUpdate
	@I_vFlockPulletGrowerID int
	,@I_vFlockID int
	,@I_vPulletGrowerID int
	,@I_vExpectedNumberToHouse int = 0
	,@I_vTotalHoused int = 0
	,@I_vAgeAtHousing int = 0
	,@I_vNPIP varchar(50) = ''
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS
if @I_vFlockPulletGrowerID = 0
begin
	insert into FlockPulletGrower (
		
		FlockID
		, PulletGrowerID
		, ExpectedNumberToHouse
		, TotalHoused
		, AgeAtHousing
		, NPIP
	)
	select
		
		@I_vFlockID
		,@I_vPulletGrowerID
		,@I_vExpectedNumberToHouse
		,@I_vTotalHoused
		,@I_vAgeAtHousing
		,@I_vNPIP
end
else
begin
	update FlockPulletGrower
	set
		
		FlockID = @I_vFlockID
		,PulletGrowerID = @I_vPulletGrowerID
		,ExpectedNumberToHouse = @I_vExpectedNumberToHouse
		,TotalHoused = @I_vTotalHoused
		,AgeAtHousing = @I_vAgeAtHousing
		,NPIP = @I_vNPIP
	where @I_vFlockPulletGrowerID = FlockPulletGrowerID
end