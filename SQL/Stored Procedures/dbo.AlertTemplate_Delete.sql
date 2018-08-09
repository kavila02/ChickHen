
create proc AlertTemplate_Delete
	@I_vAlertTemplateID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS

--foreign keys exist for this table. These should 
delete from AlertTemplate where AlertTemplateID = @I_vAlertTemplateID