if not exists (Select 1 from sys.tables where name = 'FlockChecklist_Detail_Vaccine')
begin
	create table FlockChecklist_Detail_Vaccine
	(
		FlockChecklist_Detail_VaccineID int primary key identity(1,1)
		,FlockChecklist_DetailID int foreign key references FlockChecklist_Detail(FlockChecklist_DetailID)
		,VaccineID int foreign key references Vaccine(VaccineID)
	)
end