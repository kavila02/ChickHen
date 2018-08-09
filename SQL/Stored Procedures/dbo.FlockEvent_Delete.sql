create proc FlockEvent_Delete
	@I_vFlockEventID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from FlockEvent where FlockEventID = @I_vFlockEventID