if not exists (select 1 from sys.tables where name = 'ContactRole')
begin
create table ContactRole
(
	ContactRoleID int primary key identity(1,1)
	,RoleName nvarchar(255)
	--RoleType
)
end