if not exists (select 1 from sys.tables where name = 'Detail_Status')
begin
create table Detail_Status
(
	Detail_StatusID int primary key identity(1,1)
	,Detail_Status nvarchar(255)
	,SortOrder int
	,IsActive bit
)
end

delete from Detail_Status
set identity_insert Detail_Status on
insert into Detail_Status (Detail_StatusID, Detail_Status, SortOrder, IsActive)
select 1, 'Not Started',1,1
union all select 2, 'In Progress',2,1
union all select 3, 'Completed',3,1
union all select 4, 'Deferred',4,1
union all select 5, 'N/A',5,1

set identity_insert Detail_Status off