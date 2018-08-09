if not exists (Select 1 from sys.tables where name = 'ChecklistTemplate_Detail_Vaccine')
begin
	create table ChecklistTemplate_Detail_Vaccine
	(
		ChecklistTemplate_Detail_VaccineID int primary key identity(1,1)
		,ChecklistTemplate_DetailID int foreign key references ChecklistTemplate_Detail(ChecklistTemplate_DetailID)
		,VaccineID int foreign key references Vaccine(VaccineID)
	)
end