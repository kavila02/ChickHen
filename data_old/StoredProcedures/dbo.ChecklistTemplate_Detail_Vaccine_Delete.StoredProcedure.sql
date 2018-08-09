if exists (select 1 from sys.procedures p inner join sys.schemas s on p.schema_id = s.schema_id where p.name = 'ChecklistTemplate_Detail_Vaccine_Delete' and s.name = 'dbo')
begin
	drop proc ChecklistTemplate_Detail_Vaccine_Delete
end
GO
create proc ChecklistTemplate_Detail_Vaccine_Delete
	@I_vChecklistTemplate_Detail_VaccineID int
	,@O_iErrorState int=0 output
	,@oErrString varchar(255)='' output
	,@iRowID varchar(255)=NULL output
AS


delete from ChecklistTemplate_Detail_Vaccine where ChecklistTemplate_Detail_VaccineID = @I_vChecklistTemplate_Detail_VaccineID