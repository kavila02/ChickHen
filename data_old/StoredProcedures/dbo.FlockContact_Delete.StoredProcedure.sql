if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockContact_Delete' and s.name = 'dbo')
begin
	drop proc FlockContact_Delete
end
GO
create proc FlockContact_Delete
	@I_vFlockContactID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from FlockContact where FlockContactID = @I_vFlockContactID