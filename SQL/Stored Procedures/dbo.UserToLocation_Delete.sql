create proc UserToLocation_Delete
	@I_vUserToLocationID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from UserToLocation where UserToLocationID = @I_vUserToLocationID