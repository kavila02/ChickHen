if not exists (select 1 from sys.tables where name = 'VaccineDisease')
begin
	create table VaccineDisease
	(
		VaccineDiseaseID int primary key identity(1,1)
		,VaccineID int foreign key references Vaccine(VaccineID)
		,DiseaseID int foreign key references Disease(DiseaseID)
	)
	create nonclustered index IX_VaccineDisease_VaccineID
	on VaccineDisease(VaccineID)
	create nonclustered index IX_VaccineDisease_DiseaseID
	on VaccineDisease(DiseaseID)
end

if not exists (select 1 from VaccineDisease)
begin
	insert into VaccineDisease(DiseaseID, VaccineID)
	select 1, VaccineID from Vaccine where VaccineName in ('Poulvac E.coli','Ft. Dodge Poulvac E. coli (e.coli)')
	union select 2, VaccineID from Vaccine where VaccineName in ('LAH Avipro IB ARK 6818','Poulvac Bron GA98')
	union select 3, VaccineID from Vaccine where VaccineName in ('Biomune-Layermune 3 (0.25 mL)')
	union select 4, VaccineID from Vaccine where VaccineName in ('MERCK Trachivax-eyedrop')
	union select 5, VaccineID from Vaccine where VaccineName in ('Zoetis AE-POXINE')
	union select 6, VaccineID from Vaccine where VaccineName in ('LAH Avipro Polybanco 1537-K','Zoetis-LS Mass II (Fine Spray)')
	union select 1, VaccineID from Vaccine where VaccineName in ('LAH Avipro Polybanco 1537-K','Zoetis-LS Mass II (Fine Spray)')
end