if not exists (select 1 from sys.tables where name = 'Checklist_DetailType')
begin
	create table Checklist_DetailType
	(
		Checklist_DetailTypeID int primary key identity(1,1)
		,Checklist_DetailType nvarchar(255)
		,SortOrder int
		,Active bit
	)
end

if not exists (select 1 from Checklist_DetailType)
begin
	insert into Checklist_DetailType (Checklist_DetailType, SortOrder, Active)
	select 'Initial Flock Setup/Flock Master',1,1
	union all select 'Vaccine/Feed Additive/Medication',2,1
	union all select 'Blook and Environmental Testing',3,1
	union all select 'Operational',4,1
end

