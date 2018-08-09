if not exists (select 1 from sys.tables where name = 'Disease')
begin
	create table Disease
	(
		DiseaseID int primary key identity(1,1)
		,DiseaseName varchar(100)
		,SortOrder int
		,IsActive bit
	)
end

if not exists (select 1 from Disease)
begin
	set Identity_insert Disease on
	insert into Disease (DiseaseID, DiseaseName, SortOrder, IsActive)
	select 1,'E. Coli',1,1
	union select 2,'Bronchitis',2,1
	union select 3,'Salmonella Enteritidis',3,1
	union select 4,'Laryngotracheitis',4,1
	union select 5,'Avian Encephalomyelitis-Fowl Pox',5,1
	union select 6,'Newcastle-Bronchitis',6,1
	set identity_insert disease off

end

if exists (select 1 from Disease)
begin
	update Disease set DiseaseName = 'Newcastle' where DiseaseID = 6
end

--Now a many-to-many, so using VaccineDiseaseTable
--if exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Vaccine' and c.name = 'DiseaseID')
--begin
--	declare @sql nvarchar(max) = '
--	if not exists (select 1 from Vaccine where IsNull(DiseaseID,0) > 0)
--	begin
--		update Vaccine set DiseaseID = 1 where VaccineName in (''Poulvac E.coli'',''Ft. Dodge Poulvac E. coli (e.coli)'')
--		update Vaccine set DiseaseID = 2 where VaccineName in (''LAH Avipro IB ARK 6818'',''Poulvac Bron GA98'')
--		update Vaccine set DiseaseID = 3 where VaccineName in (''Biomune-Layermune 3 (0.25 mL)'')
--		update Vaccine set DiseaseID = 4 where VaccineName in (''MERCK Trachivax-eyedrop'')
--		update Vaccine set DiseaseID = 5 where VaccineName in (''Zoetis AE-POXINE'')
--		update Vaccine set DiseaseID = 6 where VaccineName in (''LAH Avipro Polybanco 1537-K'',''Zoetis-LS Mass II (Fine Spray)'')
--	end'
--	exec(@sql)
--end