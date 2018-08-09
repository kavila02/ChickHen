
create proc [dbo].[AdditiveDisease_Delete]
	@I_vAdditiveDiseaseID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from AdditiveDisease where AdditiveDiseaseID = @I_vAdditiveDiseaseID