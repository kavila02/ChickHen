if not exists (select 1 from sys.tables where name = 'Vaccine')
begin
create table Vaccine
(
	VaccineID int primary key identity(1,1)
	,VaccineName nvarchar(255)
	,ActiveStartDate date
	,ActiveEndDate date
	,ReplacementVaccineID int --in the case one vaccine is discontinued and we need to replace it with another one
	,DiseaseID int null foreign key references Disease(DiseaseID)
	,SortOrder int
)
end



if not exists (select 1 from Vaccine)
begin
	insert into Vaccine (VaccineName,ActiveStartDate)
	select 'Poulvac E.coli',GETDATE()
	union select 'LAH Avipro Polybanco 1537-K',GETDATE()
	union select 'Poulvac Bron GA98',GETDATE()
	union select 'LAH Avipro IB ARK 6818',GETDATE()
	union select 'LAH Megan Egg (ST)',GETDATE()
	union select 'Zoetis AE-POXINE',GETDATE()
	union select 'Select 5377-15 (PP)',GETDATE()
	union select 'MERCK Trachivax-eyedrop',GETDATE()
	union select 'LAH MG-F (MG)-eyedrop',GETDATE()
	union select 'Zoetis-LS Mass II (Fine Spray)',GETDATE()
	union select 'Biomune-Layermune 3 (0.25 mL)',GETDATE()
	--union select 'PS-2/ FDA Pullet Swabs',GETDATE()
	union select 'Ft. Dodge Poulvac E. coli (e.coli)',GETDATE()

end


--if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Vaccine' and c.name = 'DiseaseID')
--begin
--	alter table Vaccine add DiseaseID int null foreign key references Disease(DiseaseID)
--end

if exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Vaccine' and c.name = 'DiseaseID')
begin
	declare @sql nvarchar(500)
	select @sql = 'alter table Vaccine drop constraint ' + rtrim(fk2.name)
	from sys.foreign_key_columns fk
				inner join sys.tables t on fk.parent_object_id = t.object_id and t.name = 'Vaccine'
				inner join sys.columns c on fk.parent_object_id = c.object_id and fk.parent_column_id = c.column_id and c.name = 'DiseaseID'
				inner join sys.tables t2 on fk.referenced_object_id = t2.object_id and t2.name = 'Disease'
				inner join sys.columns c2 on fk.referenced_object_id = c2.object_id and fk.referenced_column_id = c2.column_id and c2.name = 'DiseaseID'
				inner join sys.foreign_keys fk2 on fk.constraint_object_id = fk2.object_id
	exec (@sql)
	alter table Vaccine drop column DiseaseID
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'Vaccine' and c.name = 'SortOrder')
begin
	alter table Vaccine add SortOrder int
end