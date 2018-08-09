if not exists (select 1 from sys.tables where name = 'PulletMover')
begin
create table PulletMover
(
	PulletMoverID int primary key identity(1,1)
	,PulletMover nvarchar(255)
	,SortOrder int
	,IsActive bit
)
end
If not exists (select 1 from PulletMover)
	insert into PulletMover (PulletMover, SortOrder, IsActive)
	select 'Melhorn',1,1
	union select 'Mainjoy',2,1