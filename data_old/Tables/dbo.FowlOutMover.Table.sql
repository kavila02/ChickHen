if not exists (select 1 from sys.tables where name = 'FowlOutMover')
begin
create table FowlOutMover
(
	FowlOutMoverID int primary key identity(1,1)
	,FowlOutMover nvarchar(255)
	,SortOrder int
	,IsActive bit
)
end

if not exists (select 1 from FowlOutMover)
	insert into FowlOutMover(FowlOutMover, SortOrder, IsActive)
		select 'Melhorn',1,1
		union select 'Mainjoy',2,1