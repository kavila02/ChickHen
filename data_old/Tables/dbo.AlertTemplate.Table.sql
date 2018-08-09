if not exists (select 1 from sys.tables where name = 'AlertTemplate')
begin
create table AlertTemplate
(
	AlertTemplateID int primary key identity(1,1)
	,AlertName nvarchar(100)
	,SortOrder smallint
	,alertSubject nvarchar(100)
	,alertBody nvarchar(max)
	,IsActive bit
)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'AlertTemplate' and c.name = 'alertSubject')
begin
	alter table AlertTemplate add alertSubject nvarchar(100)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'AlertTemplate' and c.name = 'AlertName')
begin
	alter table AlertTemplate add AlertName nvarchar(100)
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'AlertTemplate' and c.name = 'SortOrder')
begin
	alter table AlertTemplate add SortOrder smallint
end

if not exists (select 1 from sys.columns c inner join sys.tables t on c.object_id = t.object_id where t.name = 'AlertTemplate' and c.name = 'IsActive')
begin
	alter table AlertTemplate add IsActive bit
end