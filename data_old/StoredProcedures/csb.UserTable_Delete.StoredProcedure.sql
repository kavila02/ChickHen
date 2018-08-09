if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'UserTable_Delete' and s.name = 'csb')
begin
	drop proc csb.UserTable_Delete
end
GO
create PROC csb.UserTable_Delete
@I_vUserTableID int
, @O_iErrorState int=0 output 
, @oErrString varchar(255)='' output
, @iRowID int=0 output
AS

delete from UserToLocation where UserTableID = @I_vUserTableID
delete from csb.UserTable where UserTableID = @I_vUserTableID