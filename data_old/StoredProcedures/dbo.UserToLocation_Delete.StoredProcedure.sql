if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'UserToLocation_Delete' and s.name = 'dbo')
begin
	drop proc UserToLocation_Delete
end
GO
create proc UserToLocation_Delete
	@I_vUserToLocationID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from UserToLocation where UserToLocationID = @I_vUserToLocationID