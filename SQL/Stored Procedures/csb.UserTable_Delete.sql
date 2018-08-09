create PROC csb.UserTable_Delete
@I_vUserTableID int
, @O_iErrorState int=0 output 
, @oErrString varchar(255)='' output
, @iRowID int=0 output
AS

delete from UserToLocation where UserTableID = @I_vUserTableID
delete from csb.UserTable where UserTableID = @I_vUserTableID