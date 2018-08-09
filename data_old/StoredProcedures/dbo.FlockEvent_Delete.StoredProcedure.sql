if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'FlockEvent_Delete' and s.name = 'dbo')
begin
	drop proc FlockEvent_Delete
end
GO
create proc FlockEvent_Delete
	@I_vFlockEventID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from FlockEvent where FlockEventID = @I_vFlockEventID