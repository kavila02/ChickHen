create proc ChecklistTemplate_Detail_Vaccine_Delete
	@I_vChecklistTemplate_Detail_VaccineID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from ChecklistTemplate_Detail_Vaccine where ChecklistTemplate_Detail_VaccineID = @I_vChecklistTemplate_Detail_VaccineID