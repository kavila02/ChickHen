
CREATE proc [dbo].[FlockPulletGrower_InsertUpdate]
	@I_vFlockPulletGrowerID int
	,@I_vFlockID int
	,@I_vPulletGrowerID int
	,@I_vExpectedNumberToHouse int = 0
	,@I_vTotalHoused varchar(20) = '0'
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
		,convert(int,dbo.csiStripNonNumericFromString(@I_vTotalHoused))
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
		,TotalHoused = convert(int,dbo.csiStripNonNumericFromString(@I_vTotalHoused))
		,AgeAtHousing = @I_vAgeAtHousing
		,NPIP = @I_vNPIP
	where @I_vFlockPulletGrowerID = FlockPulletGrowerID
end