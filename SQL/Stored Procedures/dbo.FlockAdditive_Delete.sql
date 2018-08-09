create proc FlockAdditive_Delete
	@I_vFlockAdditiveID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from FlockAdditive where FlockAdditiveID = @I_vFlockAdditiveID