if not exists (Select 1 from sys.tables t inner join sys.schemas s on t.schema_id = s.schema_id where s.name = 'csb' and t.name = 'UserTable')
begin

CREATE TABLE [csb].[UserTable](
	[UserTableID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [varchar](255) NOT NULL,
	[EmailAddress] [varchar](255) NULL,
	[UserGroupID] [int] NULL foreign key references UserGroup(UserGroupID),
	[ContactName] [varchar](255) NULL,
	[Inactive] [bit] NOT NULL DEFAULT ((0)),
	--LocationID int null foreign key references Location(LocationID),
PRIMARY KEY CLUSTERED 
(
	[UserTableID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
end
go

If exists (select * from sys.columns where object_id = object_id('csb.UserTable') and name = 'LocationID')
begin
	declare @foreignkey nvarchar(200) = 
	(select name from sys.foreign_keys where parent_object_id = object_id('csb.UserTable') and referenced_object_id = object_id('dbo.Location'))
	declare @sql nvarchar(500) = 'alter table csb.UserTable drop constraint ' + @foreignkey
	exec(@sql)
	alter table csb.UserTable drop column LocationID 
end