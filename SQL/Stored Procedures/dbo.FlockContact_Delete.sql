
create proc [dbo].[FlockContact_Delete]
	@I_vFlockContactID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from FlockContact where FlockContactID = @I_vFlockContactID