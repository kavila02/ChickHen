if not exists (select 1 from sys.tables where name = 'Attachment')
begin
create table Attachment
(
	AttachmentID int primary key identity(1,1)
	,FileDescription nvarchar(255)
	,[Path] nvarchar(2000)
	,DisplayName nvarchar(500)
	,DriveName nvarchar(50)
	,FileSize int
)
end