if not exists (select 1 from sys.tables where name = 'FieldReference')
begin
	create table FieldReference
	(
		FieldReferenceID int primary key identity(1,1)
		,TableName nvarchar(255)
		,FieldName nvarchar(255)
		,FriendlyName nvarchar(255)
		,SortOrder int
		,IsActive bit
		,DateField bit
		,ToolTip nvarchar(255)
	)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FieldReference' and c.name = 'SortOrder')
begin
	alter table FieldReference add SortOrder int
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FieldReference' and c.name = 'IsActive')
begin
	alter table FieldReference add IsActive int
end
GO


if not exists (select 1 from FieldReference where SortOrder is not null)
begin
	update FieldReference set SortOrder = FieldReferenceID
end
if not exists (select 1 from FieldReference where IsActive is not null)
begin
	update FieldReference set IsActive = 1
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'FieldReference' and c.name = 'DateField')
begin
	alter table FieldReference add DateField bit
	,ToolTip nvarchar(255)
end


go


If not exists (select 1 from FieldReference)
begin
	insert into FieldReference (TableName, FieldName, FriendlyName,SortOrder,IsActive)
	select 'Flock','OldOutDate','Old Out Date',8,1
	union select 'Flock','OldFowlHatchDate','Old Fowl Hatch Date',7,1
	union select 'Flock','HousingOutDate','Housing Out Date',6,1
	union select 'Flock','HatchDate_First','First Hatch Date',2,1
	union select 'Flock','HatchDate_Last','Last Hatch Date',3,1
	union select 'Flock','HatchDate_Average','Hatch Date',1,1
	union select 'Flock','HousingDate_First','First Housing Date',4,1
	union select 'Flock','HousingDate_Last','Last Housing Date',5,1
	union select 'Flock','HousingDate_Average','Housing Date',2,1
end

go

declare @insertable table (ColumnName nvarchar(50), friendlyName nvarchar(50), sortOrder int)
insert into @insertable
select 'OldOutDate','Previous Flock Out Date',1
union select 'FlockName','Flock Name',2
union select 'LayerHouseID','Layer House',3
union select 'ProductBreedID','Product/Breed',4
union select 'FowlAge','Fowl Age (weeks)',5
union select 'HatcheryID','Hatchery',6
union select 'HatchDate_First','First Hatch Date',7
union select 'HatchDate_Last','Last Hatch Date',8
union select 'HatchDate_Average','Hatch Date (Avg)',9
union select 'TotalChicksPlaced','Total Chicks Placed',10
union select 'PulletsMovedID','Pullet Housing Transportation',11
union select 'OrderNumber','Order Number',12
union select 'NumberChicksOrdered','Number of Chicks Ordered',13
union select 'HousingDate_First','First Housing Date',14
union select 'HousingDate_Last','Last Housing Date',15
union select 'HousingDate_Average','Housing Date (Avg)',16
union select 'AgeAtHousing_Weeks','Age at Housing (weeks)',17
union select 'AgeAtHousing_Days','Age at Housing (days)',18
union select 'TotalHoused','Total Housed',19
union select 'FowlOutID','Fowl Out Transportation',20
union select 'HousingOutDate','Final Fowl Out Date',21
union select 'ServiceTechID','Service Tech',22
union select 'ServicesNotes','Services Notes',23

insert into FieldReference (TableName, FieldName, FriendlyName,SortOrder,IsActive)
select
	'Flock', ColumnName, friendlyName, sortOrder, 1
from @insertable
where ColumnName not in (select FieldName from FieldReference)

update fr
	set fr.SortOrder = i.SortOrder
from FieldReference fr
inner join @insertable i on fr.FieldName = i.ColumnName


update FieldReference set DateField = 1 where FieldName like '%date%'
update FieldReference set DateField = 0 where DateField is null
GO

