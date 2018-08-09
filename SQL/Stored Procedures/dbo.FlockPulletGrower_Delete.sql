
create proc [dbo].[FlockPulletGrower_Delete]
	@I_vFlockPulletGrowerID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from FlockPulletGrower where FlockPulletGrowerID = @I_vFlockPulletGrowerID